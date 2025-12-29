# frozen_string_literal: true

require "active_model"
require "active_support/concern"
require "active_support/core_ext/hash"

module Input
  # Core module that provides the Input DSL and runtime behavior.
  #
  # Responsibilities:
  # - Provide `optional` and `required` builders for declaring keys.
  # - Keep registry of keys and defaults on the class.
  # - Provide instance-level accessors and `valid?` flow (apply defaults,
  #   run validations).
  #
  # This file intentionally keeps control flow minimal; the heavy lifting of
  # validation rules is implemented in `Builder`.
  extend ActiveSupport::Concern
  include ActiveModel::Validations

  included do
    @keys = {}
    @defaults = {}
    @strip_unknown_attributes = false
    @transforms = {}
  end

  # Instance methods -------------------------------------------------
  def initialize(attributes = {})
    # Initialize the input object with a hash of attributes. This keeps an
    # internal indifferent-access hash for convenient lookups.
    @attributes = attributes.is_a?(Hash) ? attributes.with_indifferent_access : {}
    strip_unknown_if_configured
    @validated = false
  end

  # Read an attribute value (symbol or string key).
  def [](name)
    # Read attribute value by symbol or string key (indifferent access wrapper)
    @attributes[name.to_sym] || @attributes[name.to_s]
  end

  # Provide dynamic dot-style accessors for declared keys. This allows
  # `address` instead of `self[:address]` inside validation methods.
  # When a nested Input class is registered for the key, this returns an
  # instance of that nested class initialized with the hash value.
  def method_missing(name, *args, &)
    name_sym = name.to_sym
    keys = self.class.instance_variable_get(:@keys) || {}
    return super unless keys.key?(name_sym)

    value = self[name_sym]
    cast_nested_value(name_sym, value)
  end

  def respond_to_missing?(name, include_private = false)
    keys = self.class.instance_variable_get(:@keys) || {}
    keys.key?(name.to_sym) || super
  end

  # Set an attribute value.
  def []=(name, value)
    # Set attribute by normalizing to symbol key in the internal hash
    @attributes[name.to_sym] = value
  end

  def key?(name)
    @attributes.key?(name.to_sym) || @attributes.key?(name.to_s)
  end

  def attributes
    @attributes.to_h.deep_symbolize_keys
  end

  # Output representation of the input attributes as a plain symbol-keyed hash.
  def output
    out = attributes.dup
    transforms = self.class.instance_variable_get(:@transforms) || {}
    transforms.each do |from, to|
      from = from.to_sym
      next unless out.key?(from)

      val = out.delete(from)
      out[to.to_sym] = normalize_transformed_value(from, val)
    end
    out
  end

  # Apply configured defaults and run ActiveModel validations
  def valid?(*_)
    apply_defaults
    @validated = true
    super
  end

  private

  # Apply defaults collected by Builder on the class.
  def apply_defaults
    defaults = self.class.instance_variable_get(:@defaults) || {}
    defaults.each { |key, value| self[key] = value unless key?(key) }
  end

  def cast_nested_value(name_sym, value)
    if nested_classes[name_sym] && value.is_a?(Hash)
      nested_classes[name_sym].new(value)
    elsif nested_array[name_sym] && value.is_a?(Array)
      nested_klass = nested_array[name_sym]
      value.map { |e| e.is_a?(Hash) ? nested_klass.new(e) : e }
    else
      value
    end
  end

  # Class methods ----------------------------------------------------
  module ClassMethods
    # Ensure child classes inherit registries.
    def inherited(base)
      super
      base.instance_variable_set(:@keys, @keys.dup)
      base.instance_variable_set(:@nested_classes, (@nested_classes || {}).dup)
      base.instance_variable_set(:@nested_array_classes, (@nested_array_classes || {}).dup)
      base.instance_variable_set(:@defaults, (@defaults || {}).dup)
      base.instance_variable_set(:@strip_unknown_attributes, @strip_unknown_attributes)
      base.instance_variable_set(:@transforms, (@transforms || {}).dup)
    end

    # Define an optional key and return a `Builder` to configure it.
    def optional(name)
      define_key(name, required: false)
      Builder.new(self, name.to_sym)
    end

    # Define a required key and return a `Builder` to configure it.
    def required(name)
      define_key(name, required: true)
      Builder.new(self, name.to_sym)
    end

    # When declared, any attributes not declared with `required/optional`
    # will be removed from input instances on initialization.
    def strip_unknown_attributes
      @strip_unknown_attributes = true
    end

    # DSL entry for transforming an attribute key to another key on output.
    # Usage: `transform_key(address: :address_attributes)`
    def transform_key(**mapping)
      @transforms ||= {}
      mapping.each { |k, v| @transforms[k.to_sym] = v.to_sym }
    end

    # Ensure the ActiveModel `validate` DSL is available to Input classes.
    #
    # Delegates to ActiveModel::Validations::ClassMethods#validate when
    # present so callers can write `validate :method_name` inside their
    # Input classes and have the corresponding instance method invoked
    # during validation.
    def validate(*, &)
      if defined?(ActiveModel::Validations::ClassMethods) && ActiveModel::Validations::ClassMethods.method_defined?(:validate)
        ActiveModel::Validations::ClassMethods.instance_method(:validate).bind_call(self, *, &)
      elsif defined?(super)
        super
      end
    end

    # DSL entry for transforming an attribute key to another key on output.
    # Usage: `transform(:address).to(:address_attributes)`
    def transform(name)
      TransformBuilder.new(self, name)
    end

    class TransformBuilder
      def initialize(klass, name)
        @klass = klass
        @name = name.to_sym
      end

      def to(new_name)
        unless @klass.instance_variable_get(:@transforms)
          @klass.instance_variable_set(:@transforms, {})
        end

        @klass.instance_variable_get(:@transforms)[@name] = new_name.to_sym
      end
    end

    private

    # Register a key on the class and add a presence validation if required.
    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
    def define_key(name, required: false)
      @keys ||= {}
      @keys[name.to_sym] = { required: required }
      return unless required

      validate do
        value   = self[name]
        missing = !key?(name) || value.nil?

        unless missing
          case value
          when String then missing = value.strip.empty?
          when Array, Hash then missing = value.empty?
          end
        end

        errors.add(name, :blank) if missing
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

    def key(name, required: false)
      define_key(name, required: required)
    end
  end

  def strip_unknown_if_configured
    strip = self.class.instance_variable_get(:@strip_unknown_attributes)
    return unless strip

    keys = (self.class.instance_variable_get(:@keys) || {}).keys.map(&:to_s)
    @attributes = @attributes.slice(*keys).with_indifferent_access
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def normalize_transformed_value(name, value)
    if nested_classes[name] && value.is_a?(Hash)
      nested = nested_classes[name].new(value)
      return nested.respond_to?(:output) ? nested.output : nested.attributes
    end

    if nested_array[name] && value.is_a?(Array)
      nested_klass = nested_array[name]
      return value.map do |element|
        if element.is_a?(Hash)
          nested = nested_klass.new(element)
          nested.respond_to?(:output) ? nested.output : nested.attributes
        else
          element
        end
      end
    end

    value
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

  def nested_array
    self.class.instance_variable_get(:@nested_array_classes) || {}
  end

  def nested_classes
    self.class.instance_variable_get(:@nested_classes) || {}
  end
end
