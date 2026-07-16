# frozen_string_literal: true

require "spec_helper"

RSpec.describe ExceptionHandler do
  describe "#handler" do
    let(:object) { Rarchitecture::ApplicationService::Unauthorized.new("Not allowed") }
    let(:instance) do
      Exceptions::API.allocate.tap do |api|
        api.instance_variable_set(:@object, object)
        api.instance_variable_set(:@options, {})
      end
    end

    it "resolves to the application_service_unauthorized handler" do
      expect(instance.send(:handler)).to eq("application_service_unauthorized")
    end

    it "falls back to :exception when no matching handler is defined" do
      instance.instance_variable_set(:@object, StandardError.new("boom"))

      expect(instance.send(:handler)).to eq(:exception)
    end
  end

  describe "#application_service_unauthorized" do
    it "maps Rarchitecture::ApplicationService::Unauthorized to a 403 through Exceptions::API" do
      error = Rarchitecture::ApplicationService::Unauthorized.new("Not allowed")
      api = Exceptions::API.new(error)

      expect(api.status).to eq(403)
      expect(api.error_message).to eq("Not allowed")
    end
  end
end
