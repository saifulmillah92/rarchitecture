# frozen_string_literal: true

require_relative "../base"
require_relative "api/api_generator"
require_relative "view/view_generator"

module Rarchitecture
  module Generators
    class ControllerGenerator < Rarchitecture::Generators::Base
      source_root File.expand_path("templates", __dir__)
      class_option :api, type: :boolean, default: false
      class_option :view, type: :boolean, default: false

      def ensure_controller
        api, view = resolve_controller_options

        invoke Controller::ApiGenerator  if api
        invoke Controller::ViewGenerator if view
      end

      private

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      def resolve_controller_options
        return [true, false] if options[:api] && !options[:view]
        return [false, true] if options[:view] && !options[:api]
        return [true, true]  if options[:api] && options[:view]

        answer = ask("Which controller do you want to generate? (api/view/both)", default: "both")
        case answer.downcase
        when "api"  then [true, false]
        when "view" then [false, true]
        else             [true, true]
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
    end
  end
end
