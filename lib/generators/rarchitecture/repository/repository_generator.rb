# frozen_string_literal: true

require_relative "../base"

module Rarchitecture
  module Generators
    class RepositoryGenerator < Rarchitecture::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def ensure_application_repository_and_continue
        repo_path = Rails.root.join("app/repositories/application_repository.rb")
        return if File.exist?(repo_path)

        say_status :missing, missing_repositories, :yellow
        generate "rails_architecture:init for=repository"
      end

      def create_repository_file
        repo_path = Rails.root.join("app/repositories", path, "#{name}_repository.rb")
        return template "repository.rb.tt", repo_path unless @modules.present?

        template "repository_module.rb.tt", repo_path
      end

      private

      def missing_repositories
        "application_repository.rb not found. Running init generator..."
      end
    end
  end
end
