# frozen_string_literal: true

module Input
  module Validators
    # Common
    #
    # Centralized helpers used by validator modules. This module keeps
    # shared behavior in one place so individual validator modules can
    # remain small and focused.
    #
    # Responsibilities:
    # - Format ActiveModel error objects into user-friendly messages.
    # - Register default attribute values on declaring classes.
    # - Record nested input classes for `hash` and `array` validators.
    # - Resolve constant references passed via `from:` options.
    # - Provide reusable helpers for value handling and blank checks.
    module Common
      # Format an `ActiveModel::Error` into a human-readable string.
      # Prefers a custom `:message` option when present, otherwise falls
      # back to a friendly default for `:blank`, or the error type.
      def self.format_error_message(error)
        raw = error.options[:message]
        return raw.to_s if raw && !raw.to_s.empty?

        error.type == :blank ? "can't be blank" : error.type.to_s
      end

      # Register a default value for `name` on `klass`. Defaults are
      # stored in an `@defaults` instance variable on the class so that
      # they can be applied lazily at instance validation time.
      def self.add_default(klass, name, value)
        unless klass.instance_variable_defined?(:@defaults)
          klass.instance_variable_set(:@defaults, {})
        end

        defaults = klass.instance_variable_get(:@defaults)
        defaults[name] ||= value unless value.blank?
      end

      # Record a nested Input class for an array attribute. The entry is
      # stored on the owning class under `@nested_array_classes` keyed by
      # the attribute name so validation and transformation can locate it.
      def self.add_nested_array_class(klass, name, nested_klass)
        unless klass.instance_variable_defined?(:@nested_array_classes)
          klass.instance_variable_set(:@nested_array_classes, {})
        end

        klass.instance_variable_get(:@nested_array_classes)[name] = nested_klass
      end

      # Record a nested Input class for a hash attribute. Stored on the
      # declaring class under `@nested_classes` keyed by attribute name.
      def self.add_nested_class(klass, name, nested_klass)
        unless klass.instance_variable_defined?(:@nested_classes)
          klass.instance_variable_set(:@nested_classes, {})
        end

        klass.instance_variable_get(:@nested_classes)[name] = nested_klass
      end

      # Resolve a constant reference passed to the DSL. Accepts either a
      # `Class` object or a constant name (String or Symbol). Returns the
      # class or nil if it cannot be resolved.
      def self.resolve_const(name)
        return nil if name.nil?
        return name if name.is_a?(Class)

        Object.const_get(name)
      rescue NameError
        nil
      end

      # Helper to fetch an attribute value and skip validation if blank
      # and `allow_blank` is true. Yields the value and record to the
      # provided block inside an instance-level `validate`.
      def self.with_value(klass, name, format, &)
        klass.validate do
          next unless attributes.key?(name)

          value = self[name]
          next if value.blank? && format[:allow_blank]

          yield(value, self, format[:message])
        end
      end

      # Add a validator that ensures the value of `name`
      # is included in the provided `any_of` list. Respects
      # `allow_blank` to skip validation on empty values,
      # and uses a custom error message if supplied.
      def self.validate_any_of_values(klass, name, **options)
        add_default(klass, name, options[:default])
        values = options[:any_of]
        return if values.blank?

        format = options[:format] || {}
        Common.with_value(klass, name, format) do |value, record, message|
          next if values.include?(value)

          message ||= "#{name.to_s.titleize} must be one of: (#{values.join(", ")})"
          record.errors.add(:base, message)
        end
      end
    end
  end
end
