# frozen_string_literal: true

#
# ApplicationInput
#

require_relative "input/builder"
require_relative "input/input"

module RArchitecture
  class ApplicationInput
    include ::Input

    # Automatically strips out any attributes not explicitly defined
    # in the input schema to prevent unexpected parameters.
    strip_unknown_attributes

    # Builds input DSL definitions (optional/required) from the given model's columns.
    #
    # For each column:
    # - Skips Rails default columns (id, created_at, updated_at).
    # - Marks the column as `optional` if it allows NULL values.
    # - Marks the column as `required` if it does not allow NULL values.
    def self.build_from_model(model)
      model.columns.each do |column|
        ignored = ["id", "created_at", "updated_at"]
        next if ignored.include?(column.name)

        column.null ? optional(column.name.to_sym) : required(column.name.to_sym)
      end
    end

    # Initializes the input object and, if a model is provided,
    # dynamically builds DSL definitions from that model's columns.
    def initialize(attributes, model: nil)
      self.class.build_from_model(model) if model
      super(attributes)
    end
  end
end
