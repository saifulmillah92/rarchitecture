# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rarchitecture::ApplicationService do
  before do
    User.clear_all
    @user = User.create(name: "Saiful", email: "saiful@example.com")
    @user2 = User.create(name: "Alex", email: "alex@example.com")
    @service = described_class.new(model: User)
  end

  it "exists" do
    expect(described_class).to be_a(Class)
  end

  context "with all method" do
    it "returns a collection of all users" do
      expect(@service.all).to eq([@user2, @user])
    end

    it "returns a collection of all users limited by 1" do
      expect(@service.all({ limit: 1 })).to eq([@user2])
    end

    it "returns a collection of all users filtered by name" do
      expect(@service.all({ name: "Saiful" })).to eq([@user])
    end

    it "returns a collection of all users filtered by email" do
      expect(@service.all({ email: "saiful@example.com" })).to eq([@user])
    end

    it "returns empty collection when no users match filter" do
      expect(@service.all({ name: "NonExistent" })).to eq([])
    end

    it "returns all collection of users when filtered by " \
       "sort_column(name) and sort_direction(desc)" do
      expect(@service.all({ sort_column: "name", sort_direction: "desc" })).to eq([@user, @user2])
    end

    it "returns all collection of users when filtered by " \
       "sort_column(name) and sort_direction(asc)" do
      expect(@service.all({ sort_column: "name", sort_direction: "asc" })).to eq([@user2, @user])
    end
  end

  context "with find method" do
    it "finds a user by id" do
      found_user = @service.find(@user.id)
      expect(found_user).to eq(@user)
    end

    it "raises an error when user not found" do
      expect { @service.find(999) }.to raise_error(
        Rarchitecture::ApplicationService::Invalid, "User not found",
      )
    end
  end

  context "with find_by method" do
    it "finds a user by id" do
      found_user = @service.find_by({ id: @user.id })
      expect(found_user).to eq(@user)
    end

    it "returns nil when user not found" do
      expect(@service.find_by({ id: 999 })).to be_nil
    end
  end

  context "with new method" do
    it "initializes a new user instance" do
      new_user = @service.new(name: "New User", email: "newuser@example.com")
      expect(new_user).to be_a(User)
      expect(new_user.name).to eq("New User")
      expect(new_user.email).to eq("newuser@example.com")
    end
  end

  context "with create method" do
    it "creates a new user with valid attributes" do
      user_params = { name: "John", email: "john@example.com" }
      created_user = @service.create(user_params)
      expect(created_user).to be_a(User)
      expect(created_user.name).to eq("John")
      expect(created_user.email).to eq("john@example.com")
    end
  end

  context "with update method" do
    it "updates a user with valid attributes" do
      expect(@user.name).to eq("Saiful")

      user_params = { name: "John" }
      updated_user = @service.update(@user.id, user_params)

      expect(updated_user).to be_a(User)
      expect(updated_user.name).to eq("John")
    end
  end

  context "with destroy method" do
    it "destroys a user by id" do
      expect(User.all.size).to eq(2)

      @service.destroy(@user.id)

      expect(User.all.size).to eq(1)
      expect(User.all).not_to include(@user)
    end
  end

  context "with count method" do
    it "returns the total count of users" do
      expect(@service.count).to eq(2)
    end

    it "returns the count of users filtered by name" do
      expect(@service.count({ name: "Saiful" })).to eq(1)
    end

    it "returns zero when no users match filter" do
      expect(@service.count({ name: "NonExistent" })).to eq(0)
    end
  end
end
