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
      def self.attach(klass, name, default: nil, **)
        add_boolean_type_check(klass, name, **)
        Common.add_default(klass, name, default)
      end

      # Add a type-checking validator ensuring the value is either
      # `true` or `false` when present. Uses an instance-level `validate`
      # block so errors are collected via ActiveModel's error store.
      def self.add_boolean_type_check(klass, name, **options)
        format = options[:format] || {}

        klass.validate do
          value = self[name]
          next if [1, true, "true", 0, false, "false"].include?(value)
          next if value.blank? && format[:allow_blank]

          errors.add(:base, format[:message] || "#{name.to_s.titleize} must be boolean")
        end
      end
    end
  end
end
