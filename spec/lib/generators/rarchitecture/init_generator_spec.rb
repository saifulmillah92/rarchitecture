# frozen_string_literal: true

require "spec_helper"
require "generators/rarchitecture/init/init_generator"

RSpec.describe Rarchitecture::Generators::InitGenerator, type: :generator do
  # Define where the generated files will go (use a tmp dir)
  destination File.expand_path("../../../../tmp", __dir__)

  before do
    prepare_destination # Cleans the tmp directory before each test
  end

  shared_examples "standard architecture files" do
    it "creates the core architecture files" do
      expect(file("app/inputs/application_input.rb")).to exist
      expect(file("app/outputs/application_output.rb")).to exist
      expect(file("app/lib/application_exception.rb")).to exist
      expect(file("app/repositories/application_repository.rb")).to exist
      expect(file("app/services/application_service.rb")).to exist
    end
  end

  context "with Api mode" do
    before { run_generator ["--api"] }

    it "creates the API controller file" do
      expect(file("app/controllers/api/application_controller.rb")).to exist
    end

    it_behaves_like "standard architecture files"
  end

  context "with View mode" do
    before { run_generator ["--view"] }

    it "overwrites the View controller file" do
      expect(file("app/controllers/application_controller.rb")).to exist
      file("app/controllers/application_controller.rb") do |content|
        expect(content).to include("Rarchitecture::ApplicationController::VIEW")
      end
    end

    it_behaves_like "standard architecture files"
  end
end
