# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rarchitecture::ApplicationPresenter do
  before do
    User.clear_all
    @user = User.create(name: "Saiful", email: "saiful@example.com")
  end

  it "exists" do
    expect(described_class).to be_a(Class)
  end

  it "returns the raw presentation hash with symbol keys" do
    result = UserPresenter.new(@user).presentation

    expect(result).to eq(id: @user.id, name: "Saiful", email: "saiful@example.com")
  end

  it "returns a JSON-compatible hash" do
    result = UserPresenter.new(@user).as_json

    expect(result).to include_json(
      id: @user.id, name: "Saiful", email: "saiful@example.com",
    )
  end

  it "uses a custom presentation method when specified" do
    result = UserPresenter.new(@user, use: :mini_presentation).as_json

    expect(result.keys).to contain_exactly("id", "email")
  end

  it "returns a Struct for a single object" do
    expect(UserPresenter.new(@user).as_struct).to be_a(Struct)
  end

  it "returns nil when the object is nil" do
    expect(UserPresenter.new(nil).as_json).to be_nil
  end

  it "presents a collection as an array of hashes" do
    alex = User.create(name: "Alex", email: "alex@example.com")
    result = UserPresenter.array(User.all).presentation

    expect(result).to contain_exactly(
      { id: @user.id, name: "Saiful", email: "saiful@example.com" },
      { id: alex.id, name: "Alex", email: "alex@example.com" },
    )
  end

  it "returns JSON-compatible hashes for a collection" do
    User.create(name: "Alex", email: "alex@example.com")
    result = UserPresenter.array(User.all).as_json

    expect(result.size).to eq(2)
    expect(result.first).to include_json(id: @user.id, name: "Saiful")
  end
end
