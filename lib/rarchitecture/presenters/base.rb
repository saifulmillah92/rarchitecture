# frozen_string_literal: true

#
# Presenters::Base
#
# Base presenter for shaping an object into a plain Ruby hash. Unlike
# Outputs::Base, a presenter carries no response envelope (no status,
# message, or root key) -- it is meant to be called from a service, or from
# inside an output, and reused across both.
#
# Responsibilities:
# - Shape a single object through an overridable `presentation` method.
# - Expose `as_json` / `to_json` / `as_struct` on top of that hash.
# - Support format variants via `use:` (e.g. `mini_presentation`).
#
# Usage:
#   Presenters::Base.new(user).presentation
#   # => { id: 1, email: "..." }
#
#   Presenters::Base.new(user).as_json
#   # => { "id" => 1, "email" => "..." }
#

require_relative "../core_ext/array"
require_relative "../core_ext/hash"

module Presenters
  class Base
    attr_reader :object, :options

    def self.array(objects, **)
      Presenters::Array.new(objects, **, item_presenter: self)
    end

    def initialize(object, options = {})
      @object = object
      @options = options
    end

    def as_json(*)
      return nil if object.nil?

      send(presentation_method).as_json(*)
    end

    def to_json(*)
      return nil if object.nil?

      send(presentation_method).to_json(*)
    end

    def as_struct
      return nil if object.nil?

      send(presentation_method).as_struct
    end

    def presentation_method
      options[:use] || :presentation
    end

    def presentation = object.as_json
    def mini_presentation = presentation
  end
end
