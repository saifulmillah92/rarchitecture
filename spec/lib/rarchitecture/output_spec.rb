# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rarchitecture::ApplicationOutput do
  before do
    User.clear_all
    @user = User.create(name: "Saiful", email: "saiful@example.com")
    @user2 = User.create(name: "Alex", email: "alex@example.com")
  end

  it "exists" do
    expect(described_class).to be_a(Class)
  end

  it "returns a valid JSON structure for array of objects" do
    options = { total: 10, limit: 10, offset: 0 }
    result = described_class.array(User.all, **options).root_json

    expect(result).to include_json(
      code: 200,
      message: "OK",
      data: [
        { name: "Saiful", email: "saiful@example.com" },
        { name: "Alex", email: "alex@example.com" },
      ],
      current_offset: 0,
      limit: 10,
      total: 10,
      next_offset: 10,
      prev_offset: 0,
    )
  end

  it "returns a valid JSON structure for single object" do
    result = described_class.new(@user).root_json

    expect(result).to include_json(
      code: 200,
      message: "OK",
      data: { name: "Saiful", email: "saiful@example.com" },
    )
  end

  it "returns a valid JSON structure for string error" do
    result = described_class::Error.new("Argument invalid").root_json
    expect(result.as_json).to include_json(
      error: { code: 422, message: "Argument invalid" },
    )
  end

  it "returns a valid JSON structure for array error" do
    result = described_class::Error.new([{ index: 1, message: "Argument invalid" }]).root_json
    expect(result.as_json).to include_json(
      error: { code: 422, message: [{ index: 1, message: "Argument invalid" }] },
    )
  end

  it "returns a valid JSON structure for hash error" do
    result = described_class::Error.new({ message: "Argument invalid" }).root_json
    expect(result.as_json).to include_json(
      error: { code: 422, message: { message: "Argument invalid" } },
    )
  end

  it "returns a valid JSON structure for object error" do
    input = UserCreationInput.new({ email: nil })
    expect(input.valid?).to be false

    result = described_class::Error.new(input).root_json
    expect(result.as_json).to include_json(
      error: { code: 422, message: "Email can't be blank" },
    )
  end

  it "returns a valid JSON structure for object array error" do
    input = UserCreationInput.new({ email: nil })
    expect(input.valid?).to be false

    result = described_class.array(input).root_json
    expect(result.as_json).to include_json(
      error: {
        code: 422,
        message: [
          { error: { message: "Email can't be blank" }, index: 0 },
        ],
      },
    )
  end

  it "returns a valid Struct data for single object" do
    result = described_class.new(@user).as_struct
    expect(result).to be_a(Struct)
  end

  it "returns a valid Struct data for array of objects" do
    result = described_class.new(User.all).as_struct
    result.all? { |record| expect(record).to be_a(Struct) }
  end

  it "returns empty data if object is nil" do
    result = described_class.new(nil).root_json

    expect(result).to include_json(
      code: 200,
      message: "OK",
      data: nil,
    )
  end

  context "with custom output" do
    it "uses the custom format method when specified for single object" do
      result = UserOutput.new(@user, use: :mini_format).as_json
      expect(result.keys).to contain_exactly("id", "email")
    end

    it "uses the custom format method when specified for array of objects" do
      result = UserOutput.array(User.all, use: :mini_format).as_json
      expect(result.first.keys).to contain_exactly("id", "email")
    end
  end
end
