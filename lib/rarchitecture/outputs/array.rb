# frozen_string_literal: true

#
# Outputs::Array
#
# Output for collections. Wraps arrays of models into API responses,
# including pagination and counter metadata when available.
#
# Usage:
#   Outputs::Array.new(users, item_output: UserOutput, total: 100).root_json
#
module Outputs
  class Array < Outputs::Base
    def initialize(*args)
      super
      @object = Array(@object)
    end

    def as_root_json
      {
        code: options[:status],
        message: options[:message],
        data: outputs,
        total: total,
        **include_counter_data,
        **(options[:metadata] || {}),
      }.as_json
    end

    def as_struct
      outputs.map { |o| item_output.new(o, **options).as_struct }
    end

    def basic_format = outputs

    def outputs
      @outputs ||= @object.map { |o| item_output.new(o, item_options) }
    end

    def output_method = :basic_format
    def item_options = options.except(:item_output, :status)
    def item_output  = options[:item_output]
    def total        = options[:total].to_i
    def limit        = (options[:limit].presence || 10).to_i
    def offset       = (options[:offset].presence || 0).to_i
    def current_page = (options[:current_page].presence || 0).to_i
    def use_page? = current_page.positive?

    def include_counter_data
      return {} unless total && limit

      use_page? ? pagination : limit_offset_counter
    end

    def next_offset  = offset + limit
    def prev_offset  = offset > limit ? offset - limit : 0

    def limit_offset_counter
      {
        limit:          limit,
        current_offset: offset,
        next_offset:    next_offset,
        prev_offset:    prev_offset,
      }
    end

    def total_pages  = (total.to_f / limit).ceil
    def next_page    = current_page < total_pages ? current_page + 1 : nil
    def prev_page    = current_page > 1 ? current_page - 1 : nil

    def pagination
      {
        pagination: {
          current_page: current_page,
          next_page:    next_page,
          prev_page:    prev_page,
          total_pages:  total_pages,
        },
      }
    end

    def error? = outputs.any?(&:error?)

    def error_format
      Outputs::Error.new(error_messages, status: error_status)
    end

    def error_messages
      outputs.each_with_index.map do |output, index|
        output.error_format.as_json.merge(index: index)
      end
    end
  end
end
