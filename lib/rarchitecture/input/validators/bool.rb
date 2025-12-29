# frozen_string_literal: true

require_relative "common"

module Input
  module Validators
    # BoolValidation
    #
    # Responsibilities:
    # - Ensure an attribute value is boolean (`true` or `false`) when present.
    # - Register a default boolean value on the declaring class.
    #
    # Usage examples:
    #   optional(:active).bool
    #   required(:confirmed).bool(default: false)
    module BoolValidation
      # Attach boolean validation to `klass` for the attribute `name`.
      # Accepts a `default` option which will be registered on the
      # declaring class if provided.
      def self.attach(klass, name, default: nil)
        add_boolean_type_check(klass, name)
        Common.handle_options(klass, name, default: default)
      end

      # Add a type-checking validator ensuring the value is either
      # `true` or `false` when present. Uses an instance-level `validate`
      # block so errors are collected via ActiveModel's error store.
      def self.add_boolean_type_check(klass, name)
        klass.validate do
          value = self[name]
          next if value.nil?

          unless [1, true, "true", 0, false, "false"].include?(value)
            errors.add(name, "must be boolean")
          end
        end
      end
    end
  end
end
