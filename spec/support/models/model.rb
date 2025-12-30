# frozen_string_literal: true

require "active_model"
require "arel"
require_relative "model_collection"

class Model
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serializers::JSON

  def self.store_record(record)
    @collections ||= []
    @collections << record
    record
  end

  # Mimic ActiveRecord's .all
  def self.all
    @collections ||= []
    ModelCollection.new(@collections, self)
  end

  # Mimic ActiveRecord's .find(id)
  # rubocop:disable Style/ImplicitRuntimeError
  def self.find(id)
    record = all.find { |r| r.id == id.to_i }
    raise "Record not found" unless record

    record
  end
  # rubocop:enable Style/ImplicitRuntimeError

  # Mimic ActiveRecord's .find_by(attributes)
  def self.find_by(attributes)
    all.find_by(attributes)
  end

  # Mimic ActiveRecord's .where(attributes)
  def self.where(attributes)
    all.select do |record|
      attributes.all? { |key, value| record.send(key) == value }
    end
  end

  # Returns an array of attribute objects, mimicking ActiveRecord's .columns
  def self.columns
    attribute_types.map do |name, type|
      is_not_null = validators_on(name).any?(ActiveModel::Validations::PresenceValidator)

      Struct.new(:name, :type, :null).new(name, type.type, !is_not_null)
    end
  end

  # Often used alongside columns_hash in Rails internals
  def self.column_names
    attribute_names
  end

  # It returns a hash of { "column_name" => TypeObject }
  def self.columns_hash
    attribute_types
  end

  def self.table_name
    name.underscore.pluralize
  end

  # Creates a virtual Arel table using the class name (lowercase/pluralized)
  def self.arel_table
    @arel_table ||= Arel::Table.new(name.underscore.pluralize)
  end

  def self.reflect_on_all_associations(macro = nil)
    @reflections ||= []
    return @reflections unless macro

    @reflections.select { |reflection| reflection.macro == macro }
  end

  # Mimic ActiveRecord::Reflection::AssociationReflection
  # Helper to register associations manually
  def self.register_reflection(macro, name, options = {})
    @reflections ||= []
    reflection = Struct.new(:macro, :name, :options).new(macro, name, options)

    def reflection.klass
      options[:class_name]&.constantize || name.to_s.classify.constantize
    end

    @reflections << reflection
  end

  # Mimic ActiveRecord's .create(attributes)
  # rubocop:disable Style/ImplicitRuntimeError
  def self.create(attributes)
    attributes = attributes.slice(*attribute_names.map(&:to_sym))
    record = new(attributes)
    raise "Record not valid: #{record.errors.full_messages.first}" unless record.valid?

    last_id = all.filter_map(&:id).compact.max || 0
    record.id = last_id + 1
    store_record(record)
    record
  end
  # rubocop:enable Style/ImplicitRuntimeError

  def self.clear_all
    @collections = []
  end

  def self.class_name
    name
  end

  # Mimic ActiveRecord's .update(attributes)
  def update(attrs = {})
    attrs.each { |key, value| send("#{key}=", value) if respond_to?("#{key}=") }
    self
  end

  # Mimic ActiveRecord's .destroy!
  def destroy!
    self.class.instance_variable_get(:@collections).delete(self)
    self
  end

  # Required for Serializers to map values correctly
  def attributes
    attribute_names.index_with(nil)
  end
end
