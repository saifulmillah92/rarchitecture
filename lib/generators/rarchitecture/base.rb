# frozen_string_literal: true

module Rarchitecture
  module Generators
    class Base < Rails::Generators::Base
      attr_reader :raw_name, :name, :modules, :path, :class_name, :table_name, :controller_name

      def initialize(args, *options)
        super
        @raw_name   = args.first
        downcased   = raw_name.split("::").map(&:downcase)
        camelized   = raw_name.split("::").map(&:camelize)

        @name       = downcased.last
        @modules    = extract_modules(downcased)
        @path       = build_path(downcased)
        @class_name = camelized.join("::")
        @table_name = downcased.join("_").pluralize
        @controller_name = camelized
      end

      def class_exists?(klass = class_name)
        Module.const_get(klass).is_a?(Class)
      rescue NameError
        raise NameError, "The class #{klass} does not exist in your Rails application."
      end

      private

      def build_path(names)
        return "" if names.size == 1

        names[0...-1].join("/")
      end

      def extract_modules(names)
        return [] if names.size == 1

        names[0...-1].map(&:titleize)
      end
    end
  end
end
