# frozen_string_literal: true

require_relative "common"

module Input
  module Validators
    # ArrayValidation
    #
    # Responsibilities:
    # - Ensure an attribute value is an Array when present.
    # - Support nested array elements where each element is a Hash that
    #   conforms to an inline `Input` class (created via a block).
    # - Register default values for array attributes on the declaring class.
    #
    # Usage examples:
    #   # simple array
    #   optional(:tags).array
    #
    #   # array of nested hashes
    #   required(:roles).array do
    #     required(:title).string
    #   end
    module ArrayValidation
      # Attach array validation to `klass` for the attribute `name`.
      # Registers a default value and, when `nested_klass` is provided,
      # validates each element against that nested Input class.
      def self.attach(klass, name, default: [], nested_klass: nil, **options)
        Common.add_default(klass, name, default)
        Common.add_nested_array_class(klass, name, nested_klass) if nested_klass

        klass.validate do
          ArrayValidation.validate_array_value(self, name, nested_klass, **options)
        end
      end

      # Validate the array value on an instance. Ensures the attribute is
      # an Array when present. Respects `allow_blank` to skip validation
      # if the attribute is not set. Iterates elements for nested validation
      # when a nested Input class is provided.
      # rubocop:disable Metrics/CyclomaticComplexity
      def self.validate_array_value(instance, name, nested_klass, **options)
        format = options[:format] || {}
        err_message = format[:message] || "#{name.to_s.titleize} must be an array"
        value = instance[name]

        return if !instance.attributes.key?(name) && format[:allow_blank]
        return instance.errors.add(:base, err_message) unless value.is_a?(Array)
        return unless nested_klass

        value.each_with_index do |elem, i|
          validate_array_element(instance, name, i, elem, nested_klass)
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      # Validate a single element inside the array. For nested objects,
      # each element must be a Hash validated by the provided nested
      # Input class. Errors are re-keyed to include the element index
      # (e.g. `roles[0].title`).
      def self.validate_array_element(instance, name, index, element, nested_klass)
        unless element.is_a?(Hash)
          instance.errors.add("#{name}[#{index}]", "must be a hash")
          return
        end

        nested = nested_klass.new(element)
        return if nested.valid?

        nested.errors.each do |err|
          message = format_error_message(err)
          instance.errors.add("#{name}[#{index}].#{err.attribute}", message)
        end
      end

      # Format an `ActiveModel::Error` into a human-friendly message.
      def self.format_error_message(err)
        Common.format_error_message(err)
      end
    end
  end
end
