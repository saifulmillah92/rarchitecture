# frozen_string_literal: true

require_relative "outputs/base"
require_relative "outputs/array"
require_relative "outputs/error"

module RArchitecture
  class ApplicationOutput < Outputs::Base
    class Array < Outputs::Array; end
    class Error < Outputs::Error; end
  end
end
