# frozen_string_literal: true

require_relative "repositories/base"
require_relative "modules/sortable"

module Rarchitecture
  class ApplicationRepository < Rarchitecture::Repositories::Base
    include Sortable

    # Enables the `sort_by` DSL( Domain‑Specific Language) for repositories.
    # Example usage in a subclass:
    sort_by :id, :desc
  end
end
