# frozen_string_literal: true

require_relative "hash"

class Array
  def as_struct
    return [] if empty?

    map do |value|
      next value unless value.is_a?(Hash) || value.is_a?(Array)

      value.as_struct
    end
  end
end
