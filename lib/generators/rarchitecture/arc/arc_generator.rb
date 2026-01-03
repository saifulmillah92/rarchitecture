# frozen_string_literal: true

require_relative "../base"
require_relative "../repository/repository_generator"
require_relative "../service/service_generator"
require_relative "../output/output_generator"
require_relative "../input/input_generator"
require_relative "../controller/api/api_generator"
require_relative "../controller/view/view_generator"

module Rarchitecture
  module Generators
    class ArcGenerator < Rarchitecture::Generators::Base
      desc "Generate repository, service, output, etc."
      class_option :api, type: :boolean, default: false
      class_option :view, type: :boolean, default: false

      def create_all_file
        invoke RepositoryGenerator
        invoke ServiceGenerator
        invoke InputGenerator
        invoke OutputGenerator

        params = { message: false, service_exist: true, output_exist: true }
        api, view = resolve_controller_options

        invoke Controller::ApiGenerator,  args, **params if api
        invoke Controller::ViewGenerator, args, **params if view
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
