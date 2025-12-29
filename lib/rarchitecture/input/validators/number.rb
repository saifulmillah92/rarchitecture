# frozen_string_literal: true

require_relative "common"

module Input
  module Validators
    # NumberValidation
    #
    # Responsibilities:
    # - Ensure an attribute value is Numeric when present.
    # - Optionally enforce digit-length constraints via `min`/`max`.
    # - Register a default value on the declaring class when provided.
    #
    # Usage examples:
    #   optional(:age).number
    #   required(:phone).number(min: 10, max: 13)
    module NumberValidation
      # Attach number validations to `klass` for the attribute `name`.
      # Accepts `default`, `min`, and `max` to configure digit-length
      # constraints. Extra options are ignored for forward compatibility.
      def self.attach(klass, name, **)
        add_numeric_type_check(klass, name)
        Common.handle_options(klass, name, **)
      end

      # Add a type-checking validator that ensures the value is Numeric
      # when present. Implemented as an instance `validate` block on the
      # declaring class to align with ActiveModel semantics.
      def self.add_numeric_type_check(klass, name)
        klass.validate do
          value = self[name]
          next if value.nil?

          errors.add(name, "must be a number") unless value.is_a?(Numeric)
        end
      end
    end
  end
end
