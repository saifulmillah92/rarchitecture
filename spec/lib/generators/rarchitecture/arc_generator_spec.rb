# frozen_string_literal: true

require "spec_helper"
require "generators/rarchitecture/arc/arc_generator"

RSpec.describe Rarchitecture::Generators::ArcGenerator, type: :generator do
  let(:tmp_path) { File.expand_path("../../../../../tmp", __dir__) }

  # Define where the generated files will go (use a tmp dir)
  destination File.expand_path("../../../../../tmp", __dir__)

  before do
    prepare_destination # Cleans the tmp directory before each test

    # Create a dummy bin/rails so generator sub-invocations don't crash
    bin_path = Pathname.new(tmp_path).join("bin")
    FileUtils.mkdir_p(bin_path)
    File.open(bin_path.join("rails"), "w") { |f| f.write("#!/usr/bin/env ruby\n") }
    FileUtils.chmod("+x", bin_path.join("rails"))

    # Mock Rails.root as before
    allow(Rails).to receive(:root).and_return(Pathname.new(tmp_path))

    # Create a dummy routes.rb file
    # This prevents Errno::ENOENT when your generator calls File.read
    config_path = Pathname.new(tmp_path).join("config")
    FileUtils.mkdir_p(config_path)
    File.open(config_path.join("routes.rb"), "w") do |f|
      f.write("Rails.application.routes.draw do\nend")
    end
  end

  shared_examples "standard architecture files" do
    it "creates the core architecture files" do
      expect(file("app/inputs/user_creation_input.rb")).to exist
      expect(file("app/inputs/user_update_input.rb")).to exist
      expect(file("app/outputs/user_output.rb")).to exist
      expect(file("app/repositories/user_repository.rb")).to exist
      expect(file("app/services/user_service.rb")).to exist
    end
  end

  context "with Api mode" do
    before do
      run_generator ["User", "--api"]
    end

    it "creates the API controller file" do
      expect(file("app/controllers/api/users_controller.rb")).to exist
    end

    it_behaves_like "standard architecture files"
  end

  context "with View mode" do
    before do
      run_generator ["User", "--view"]
    end

    it "overwrites the View controller file" do
      expect(file("app/controllers/users_controller.rb")).to exist
    end

    it_behaves_like "standard architecture files"
  end
end
