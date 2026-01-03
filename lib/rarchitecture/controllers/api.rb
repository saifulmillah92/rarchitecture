# frozen_string_literal: true

require_relative "resource"
require_relative "../application_exception"

module Controllers
  class API < ActionController::API
    include Resource

    rescue_from StandardError do |error|
      log_error(error)
      render_json error,
                  Rarchitecture::ApplicationException::API,
                  debug: !Rails.env.production?,
                  namespace: controller_path
    end

    def index
      result = service.all(**query_params)
      render_json_array result, output, **list_options
    end

    def show
      result = service.find(params[:id])
      render_json result, output, **show_options
    end

    def create
      result = service.create(permitted_params(:create))
      render_json result,
                  output,
                  message: "#{object_name} created!",
                  status: :created,
                  **show_options
    end

    def update
      result = service.update(params[:id], permitted_params(:update))
      render_json result,
                  output,
                  message: "#{object_name} updated!",
                  **show_options
    end

    def destroy
      service.destroy(params[:id])
      render_empty_json message: "#{object_name} deleted!"
    end

    private

    def render_json(model, klass = default_output, **)
      output = klass.new(model, **)
      render json: output.root_json, status: output.status
    end

    def render_error(model_or_string, **)
      render_json(model_or_string, Rarchitecture::ApplicationOutput::Error, **)
    end

    def render_empty_json(model = nil, klass = default_output, **)
      render_json(model, klass, **)
    end

    def render_json_array(array, klass = default_output, **)
      output = klass.array(array, **)
      render json: output.root_json, status: output.status
    end

    def validate!(model, on_error = {})
      halt! render_json(model, **on_error) unless Array(model).all?(&:valid?)

      model
    end

    def list_options
      {
        use: :basic_format,
        limit: limit,
        offset: offset,
        current_page: current_page,
        total: record_counts,
      }
    end
  end
end
