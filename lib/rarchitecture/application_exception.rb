# frozen_string_literal: true

require_relative "exceptions/api"
require_relative "exceptions/view"

module Rarchitecture
  class ApplicationException
    class API < Exceptions::API; end
    class VIEW < Exceptions::VIEW; end
  end
end
