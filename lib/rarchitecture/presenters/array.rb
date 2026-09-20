# frozen_string_literal: true

#
# Presenters::Array
#
# Presenter for collections: maps every object through the same element
# presenter, mirroring Outputs::Array without the response envelope.
#
# Usage:
#   Presenters::Array.new(users, item_presenter: UserPresenter).as_json
#

module Presenters
  class Array < Presenters::Base
    def initialize(objects, options = {})
      super(Array(objects), options)
    end

    def as_json(*args)
      outputs.map { |presenter| presenter.as_json(*args) }
    end

    def as_struct
      outputs.map(&:as_struct)
    end

    def presentation = outputs
    def presentation_method = :presentation

    def outputs
      @outputs ||= object.map { |o| item_presenter.new(o, item_options) }
    end

    def item_options = options.except(:item_presenter)
    def item_presenter = options[:item_presenter]
  end
end
