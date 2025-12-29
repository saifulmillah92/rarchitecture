# frozen_string_literal: true

require_relative "common"

module Input
  module Validators
    # StringValidation
    #
    # Responsibilities:
    # - Ensure an attribute value is a String when present.
    # - Optionally enforce min/max length constraints.
    # - Register a default value on the declaring class when provided.
    #
    # Usage examples:
    #   optional(:name).string
    #   required(:code).string(min: 3, max: 10)
    module StringValidation
      # Attach string validations to `klass` for the attribute `name`.
      # Accepts `default`, `min`, and `max` options. Additional options are
      # ignored to keep the API forward-compatible.
      def self.attach(klass, name, **)
        add_string_type_check(klass, name)
        Common.handle_options(klass, name, **)
      end

      # Add a type-checking validator that ensures the value is a String
      # when present. Attached as an instance-level `validate` block on the
      # declaring class to keep validation semantics consistent.
      def self.add_string_type_check(klass, name)
        klass.validate do
          value = self[name]
          next if value.nil?

          errors.add(name, "must be a string") unless value.is_a?(String)
        end
      end
    end
  end
end
