# frozen_string_literal: true

require_relative "basic"

module Rarchitecture
  module Repositories
    class Base < Basic
      DEFAULT_LIMIT  = 10
      DEFAULT_OFFSET = 0
      TYPES = [:string, :text].freeze

      def limited
        filter(limit: @scope.limit_value)
      end

      private

      def filter_by_q(text)
        return @scope if text.blank?

        cond   = search_fields.map { |f| "LOWER(#{f}) ILIKE ?" }.join(" OR ")
        values = Array.new(search_fields.size, "%#{text.downcase}%")

        @scope.where(cond, *values)
      end

      def search_fields
        @scope.klass.columns_hash
              .select { |_, col| col.type.in?(TYPES) }
              .keys
              .reject { |name| name.in?(exclude_search_fields) }
      end

      def exclude_search_fields
        []
      end

      def custom_limit
        nil
      end

      def filter_by_limit(limit)
        value = (limit || custom_limit || DEFAULT_LIMIT).to_i
        @scope.limit(value)
      end

      def filter_by_offset(offset)
        @scope.offset((offset || DEFAULT_OFFSET).to_i)
      end

      def filter_by_page(page)
        page = page.to_i
        return @scope.offset(DEFAULT_OFFSET) if page <= 1

        per_page = @options[:limit].to_i
        @scope.offset(per_page * (page - 1))
      end
    end
  end
end
