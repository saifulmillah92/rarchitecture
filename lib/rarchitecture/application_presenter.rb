# frozen_string_literal: true

require_relative "presenters/base"
require_relative "presenters/array"

module Rarchitecture
  class ApplicationPresenter < Presenters::Base
    class Array < Presenters::Array; end
  end
end
