# frozen_string_literal: true

require "spec_helper"

RSpec.describe UsersController, type: :controller do
  render_views

  before do
    Rails.application.routes.draw do
      resources :users
    end

    User.clear_all
    @user = User.create(name: "Saiful", email: "saiful@example.com")
    @user2 = User.create(name: "Alex", email: "alex@example.com")

    allow(controller).to receive(:url_for).and_return("/spec/support/views/users")
  end

  after { Rails.application.routes_reloader.reload! }

  context "with index method" do
    it "returns ok (200) and renders index" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
    end

    it "returns ok when filtering" do
      get :index, params: { name: "Saiful" }
      expect(response).to have_http_status(:ok)
    end

    it "returns valid error path when code 500" do
      Controllers::VIEW.class_eval do
        def index
          undefined
        end
      end

      get :index
      expect(response).to have_http_status(:unprocessable_content)
      expect(response).to render_template("errors/index")
    end
  end

  context "with show method" do
    it "returns ok (200) for existing user" do
      get :show, params: { id: @user.id }
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:show)
    end

    it "returns unprocessable_content (422) when user not found" do
      get :show, params: { id: 999 }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  context "with create method" do
    it "returns unprocessable_content (422) when email is missing" do
      post :create, params: { user: { name: "John" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response).to render_template(:index)
    end

    it "returns created (found) when user is created" do
      post :create, params: { user: { email: "saiful2@example.com" } }

      expect(response).to have_http_status(:found)
      expect(User.all.last.email).to eq("saiful2@example.com")
    end
  end

  context "with update method" do
    it "returns ok (200) when user updated" do
      patch :update, params: { id: @user.id, user: { email: @user.email, name: "updated" } }

      expect(response).to have_http_status(:found)
      expect(User.all.find(@user.id).name).to eq("updated")
    end

    it "returns unprocessable_content on update failure" do
      patch :update, params: { id: @user.id, user: { email: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  context "with destroy method" do
    it "returns ok (200) after destroying a user" do
      delete :destroy, params: { id: @user.id }

      expect(response).to have_http_status(:found)
      expect(User.all.find(@user.id)).to be_blank
    end
  end
end
