# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rarchitecture::ApplicationRepository do
  before do
    User.clear_all
    @user = User.create(name: "Saiful", email: "saiful@example.com")
    @user2 = User.create(name: "Alex", email: "alex@example.com")
  end

  it "exists" do
    expect(described_class).to be_a(Class)
  end

  it "returns correct data filtered by email domain" do
    repo = described_class.new(User.all)

    expect(repo.scope.size).to eq(2)
    repo = repo.filter(email: "saiful@example.com").to_a

    expect(repo.to_a).to eq([@user])
    expect(repo.to_a.size).to eq(1)
  end

  it "returns correct data filtered by name" do
    repo = described_class.new(User.all)

    expect(repo.scope.size).to eq(2)
    repo = repo.filter(name: "Alex").to_a

    expect(repo.to_a).to eq([@user2])
    expect(repo.to_a.size).to eq(1)
  end

  it "returns correct data filtered by limit" do
    repo = described_class.new(User.all)
    expect(repo.scope.size).to eq(2)

    repo = repo.filter(limit: 1)
    expect(repo.to_a.size).to eq(1)
  end

  it "returns correct data filtered by sort_column(name) and sort_direction(asc)" do
    repo = described_class.new(User.all)
    expect(repo.scope.size).to eq(2)

    repo = repo.filter(sort_column: "name", sort_direction: "asc")
    expect(repo.to_a).to eq([@user2, @user])
  end

  it "returns correct data filtered by sort_column(id) and sort_direction(asc)" do
    repo = described_class.new(User.all)
    expect(repo.scope.size).to eq(2)

    repo = repo.filter(sort_column: "id", sort_direction: "asc")
    expect(repo.to_a).to eq([@user, @user2])
  end

  it "returns correct data filtered by sort_column(name) and sort_direction(desc)" do
    repo = described_class.new(User.all)
    expect(repo.scope.size).to eq(2)

    repo = repo.filter(sort_column: "name", sort_direction: "desc")
    expect(repo.to_a).to eq([@user, @user2])
  end
end
