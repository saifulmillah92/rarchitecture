# frozen_string_literal: true

require "spec_helper"

RSpec.describe Api::UsersController, type: :request do
  before do
    Rails.application.routes.draw do
      namespace :api do
        resources :users
      end
    end

    User.clear_all
    @user = User.create(name: "Saiful", email: "saiful@example.com")
    @user2 = User.create(name: "Alex", email: "alex@example.com")
  end

  after { Rails.application.routes_reloader.reload! }

  context "with index method" do
    it "returns a collection of all users" do
      get "/api/users"

      expect(response).to have_http_status(:ok)
    end

    it "returns a collection of all users limited by 1" do
      get "/api/users", params: { limit: 1 }
      expect(response).to have_http_status(:ok)

      expect(response_body["data"].size).to eq(1)
    end

    it "returns a collection of all users filtered by name" do
      get "/api/users", params: { name: "Saiful" }
      expect(response).to have_http_status(:ok)

      expect(response_body["data"].size).to eq(1)
      expect(response_body["data"][0]["name"]).to eq("Saiful")
    end

    it "returns a collection of all users filtered by email" do
      get "/api/users", params: { email: "saiful@example.com" }
      expect(response).to have_http_status(:ok)

      expect(response_body["data"].size).to eq(1)
      expect(response_body["data"][0]["name"]).to eq("Saiful")
    end

    it "returns empty collection when no users match filter" do
      get "/api/users", params: { name: "NonExistent" }
      expect(response).to have_http_status(:ok)

      expect(response_body["data"].size).to eq(0)
    end

    it "returns all collection of users when filtered by " \
       "sort_column(name) and sort_direction(desc)" do
      get "/api/users", params: { sort_column: "name", sort_direction: "desc" }
      expect(response).to have_http_status(:ok)
      expect(response_body["data"].size).to eq(2)
      expect(response_body["data"].pluck(:name)).to eq([@user.name, @user2.name])
    end

    it "returns all collection of users when filtered by " \
       "sort_column(name) and sort_direction(asc)" do
      get "/api/users", params: { sort_column: "name", sort_direction: "asc" }

      expect(response).to have_http_status(:ok)
      expect(response_body["data"].size).to eq(2)
      expect(response_body["data"].pluck(:name)).to eq([@user2.name, @user.name])
    end

    context "with paginations" do
      it "returns offset based pagination" do
        get "/api/users", params: { limit: 10, offset: 0 }

        expect(response).to have_http_status(:ok)
        expect(response_body).to include_json(
          current_offset: 0,
          limit: 10,
          total: 2,
          next_offset: 10,
          prev_offset: 0,
        )
      end

      it "returns page based pagination" do
        get "/api/users", params: { limit: 10, page: 1 }

        expect(response).to have_http_status(:ok)
        expect(response_body).to include_json(
          pagination: {
            current_page: 1,
            next_page: nil,
            prev_page: nil,
            total_pages: 1,
          },
        )
      end
    end
  end

  context "with show method" do
    it "finds a user by id" do
      get "/api/users/#{@user.id}"

      expect(response).to have_http_status(:ok)
      expect(response_body).to include_json(data: { id: @user.id })
    end

    it "raises an error when user not found" do
      get "/api/users/999"
      expect(response).to have_http_status(:unprocessable_content)

      expect(response_body).to include_json(
        error: { code: 422, message: "User not found" },
      )
    end
  end

  context "with create method" do
    it "returns error when email is not given" do
      post "/api/users",
           params: { name: "John" }.to_json,
           headers: { "CONTENT_TYPE" => "application/json" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response_body).to include_json(
        error: { code: 422, message: "Email can't be blank" },
      )
    end

    it "returns ok user created" do
      post "/api/users",
           params: { name: "Saiful", email: "saiful@example.com" }.to_json,
           headers: { "CONTENT_TYPE" => "application/json" }

      expect(response).to have_http_status(:created)
      expect(User.all.find(response_body[:data][:id])).to be_present
    end
  end

  context "with update method" do
    it "returns ok user udpated" do
      patch "/api/users/#{@user.id}",
            params: { name: "updated", email: @user.email }.to_json,
            headers: { "CONTENT_TYPE" => "application/json" }

      expect(response).to have_http_status(:ok)
      expect(User.all.find(@user.id).name).to eq("updated")
    end
  end

  context "with destroy method" do
    it "destroys a user by id" do
      delete "/api/users/#{@user.id}"

      expect(response).to have_http_status(:ok)
      expect(User.all.find(@user.id)).to be_blank
    end
  end

  private

  def response_body
    JSON.parse(response.body).with_indifferent_access
  end
end
