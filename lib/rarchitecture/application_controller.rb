# frozen_string_literal: true

require_relative "controllers/api"
require_relative "controllers/view"

module RArchitecture
  class ApplicationController
    class API < Controllers::API; end
    class VIEW < Controllers::VIEW; end
  end
end
