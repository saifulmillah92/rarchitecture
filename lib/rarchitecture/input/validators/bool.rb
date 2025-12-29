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
      # Registers a default value if provided and attaches a type-checking
      # validator to ensure the attribute is boolean.
      def self.attach(klass, name, default: nil, **)
        add_boolean_type_check(klass, name, **)
        Common.add_default(klass, name, default)
      end

      # Add a type-checking validator that ensures the value of `name`
      # is boolean when present. Accepts `true`, `false`, and common
      # equivalents (`1`, `0`, `"true"`, `"false"`). Respects `message`
      # for custom error messages. Attached as an instance-level `validate`
      # block so errors are collected via ActiveModel's error store.
      def self.add_boolean_type_check(klass, name, **options)
        format = options[:format] || {}

        Common.with_value(klass, name, format) do |value, record, message|
          next if [1, true, "true", 0, false, "false"].include?(value)

          record.errors.add(:base, message || "#{name.to_s.titleize} must be boolean")
        end
      end
    end
  end
end
