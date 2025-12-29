# frozen_string_literal: true

require "active_model"

class Model
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serializers::JSON

  # Returns an array of attribute objects, mimicking ActiveRecord's .columns
  def self.columns
    attribute_types.map do |name, type|
      is_not_null = validators_on(name).any?(ActiveModel::Validations::PresenceValidator)

      Struct.new(:name, :type, :null).new(name, type.type, !is_not_null)
    end
  end
end
