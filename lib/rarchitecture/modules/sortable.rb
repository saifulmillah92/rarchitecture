# frozen_string_literal: true

require "active_support"
require "active_support/core_ext/class/attribute"
require "active_support/concern"

module Sortable
  extend ActiveSupport::Concern

  included { class_attribute :sort_column, :sort_direction, instance_writer: false }

  class_methods do
    def sort_by(column, direction)
      direction = direction.to_s.downcase
      unless ["asc", "desc"].include?(direction)
        raise ArgumentError, "sort direction must be asc/desc"
      end

      self.sort_column    = column.to_s
      self.sort_direction = direction
    end

    def inherited(subclass)
      super
      subclass.sort_column    = sort_column
      subclass.sort_direction = sort_direction
    end
  end

  private

  def default_options
    {
      sort_column:    self.class.sort_column,
      sort_direction: self.class.sort_direction,
    }
  end

  def filter_by_sort_column(sort_column)
    if sort_column.present?
      validate_column = @scope.column_names.include?(sort_column.to_s)
      invalid         = ActiveModel::StrictValidationFailed
      error_message   = "Column #{sort_column} does not exist"

      raise invalid, error_message unless validate_column
    end

    case sort_direction
    when "asc"  then @scope.reorder(order_asc(sort_column))
    when "desc" then @scope.reorder(order_desc(sort_column))
    end
  end

  def order_asc(order_column)
    id_asc = column("id").asc
    return id_asc if order_column.to_s == "id"

    order_nulls = order_nulls_value || "NULLS FIRST"
    Arel.sql("#{column(order_column).asc.to_sql} #{order_nulls}, #{id_asc.to_sql}")
  end

  def order_desc(order_column)
    id_desc = column("id").desc
    return id_desc if order_column.to_s == "id"

    order_nulls = order_nulls_value || "NULLS LAST"
    Arel.sql("#{column(order_column).desc.to_sql} #{order_nulls}, #{id_desc.to_sql}")
  end

  def order_nulls_value
    order_nulls = @options[:order_nulls] || @options["order_nulls"]
    return nil if order_nulls.blank?

    order_nulls == "first" ? "NULLS FIRST" : "NULLS LAST"
  end

  def sort_column
    @options[:sort_column] || @options["sort_column"]
  end

  def sort_direction
    @options[:sort_direction] || @options["sort_direction"]
  end
end
