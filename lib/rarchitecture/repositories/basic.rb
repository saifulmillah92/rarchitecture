# frozen_string_literal: true

module Rarchitecture
  module Repositories
    class Basic
      include Enumerable

      DEFAULT_OPTIONS = {}.freeze
      TYPES = [:string, :text].freeze

      def initialize(scope = default_scope, options = nil, includes = nil)
        @scope     = scope
        @options   = default_options.merge(options.to_h).with_indifferent_access
        @includes  = Array(includes)

        define_dynamic_column_filters
        define_dynamic_association_includes

        apply_filters(@options)
        apply_includes(@includes)
      end

      def scope     = @scope.clone
      def options   = @options.clone
      def includes  = @includes.clone

      def filter(new_options)
        clone.tap do |repo|
          merged = sort_options(repo.options.merge(new_options))
          repo.instance_variable_set(:@options, merged.with_indifferent_access)
          repo.send(:apply_filters, new_options)
        end
      end

      def include(*assocs)
        clone.tap do |repo|
          merged = (repo.includes | assocs)
          repo.instance_variable_set(:@includes, merged)
          repo.send(:apply_includes, assocs)
        end
      end

      def name
        @scope.klass.model_name.human
      end

      def table_name
        @scope.klass.table_name
      end

      def include?(id)
        @scope.exists?(id)
      end

      def new(params = {})
        @scope.unscoped.new(params)
      end

      def get(id)
        @scope.find_by(id: id)
      end

      def first
        @scope.first
      end

      def last
        @scope.last
      end

      def count(...) = @scope.count(...)
      def each(&) = load(@scope).each(&)

      def inspect
        address = "0x#{(object_id << 1).to_s(16).rjust(16, "0")}"
        "#<#{self.class}:#{address} @options=#{@options}>"
      end

      def table
        @scope.arel_table
      end

      def column(name)
        table[name]
      end

      def column_names
        @scope.klass.column_names
      end

      def columns_hash(column)
        @scope.klass.columns_hash[column]
      end

      def all_associations
        @scope.klass.reflect_on_all_associations
      end

      def to_sql
        @scope.to_sql
      end

      private

      def default_scope
        raise StandardError, "default_scope not implemented in #{self.class}"
      end

      def default_options = DEFAULT_OPTIONS

      def sort_options(options)
        keys = options.keys.sort_by do |k|
          next 0 if k.to_s == "sort_direction"
          next 1 if k.to_s == "sort_column"

          2
        end

        keys.map.with_object({}) { |k, h| h[k] = options[k] }
      end

      def load(scope, limit = nil)
        return scope.limit(limit) if limit

        scope
      end

      def update_scope(new_scope)
        clone.tap { |repo| repo.instance_variable_set(:@scope, new_scope) }
      end

      def define_dynamic_column_filters
        column_names.each do |attr|
          method_name = "filter_by_#{attr}"
          next if respond_to?(method_name, true)

          define_singleton_method(method_name) do |value|
            column = columns_hash(attr)
            return @scope.where(attr => value) unless TYPES.include?(column.type)

            @scope.where("LOWER(#{table_name}.#{attr}) = ?", value.to_s.downcase)
          end
        end
      end

      def define_dynamic_association_includes
        all_associations.each do |assoc|
          name = assoc.name
          method_name = "include_#{name}"
          next if respond_to?(method_name, true)

          define_singleton_method(method_name) { @scope.includes(name) }
        end
      end

      def apply_filters(options)
        options.each do |key, value|
          method = "filter_by_#{key}"
          next unless respond_to?(method, true)

          result = send(method, value)
          @scope = result if result
        end
      end

      def apply_includes(associations)
        associations.each do |assoc|
          method = "include_#{assoc}"
          next unless respond_to?(method, true)

          result = send(method)
          @scope = result if result
        end
      end
    end
  end
end
