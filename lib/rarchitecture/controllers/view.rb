# frozen_string_literal: true

require_relative "resource"
require_relative "../application_exception"

module Controllers
  class VIEW < ActionController::Base
    include Resource

    helper_method :model
    helper_method :model_columns
    helper_method :object_name

    rescue_from StandardError do |error|
      log_error(error)
      respond_to do |format|
        format.html { handle_exception error }
      end
    end

    def index
      @objects = output.array(service.all(**query_params), **list_options).as_struct
      @total = record_counts
    end

    def new
      @object = model.new
    end

    def edit
      @object = service.find(params[:id])
    end

    def show
      @object = output.new(service.find(params[:id]), **show_options).as_struct
    end

    def create
      @object = service.create(permitted_params(:create))
      @object = output.new(@object, **show_options).as_struct

      flash.notice = "#{object_name} created!"
      redirect_to url_for(controller: controller_name, action: :index)
    end

    def update
      @object = service.update(params[:id], permitted_params(:update))
      @object = output.new(@object, **show_options).as_struct

      flash.notice = "#{object_name} updated!"
      redirect_to url_for(controller: controller_name, action: :index)
    end

    def destroy
      service.destroy(params[:id])
      flash.notice = "#{object_name} deleted!"
      redirect_to url_for(controller: controller_name, action: :index)
    end

    private

    def model_columns
      model.columns
    end

    def validate!(model)
      return model if model.valid?

      raise ActiveRecord::RecordInvalid, model
    end

    def list_options
      { use: :basic_format }
    end

    def request_body
      @request_body ||=
        request.request_parameters.symbolize_keys[controller_key.to_sym]
    end

    def handle_exception(error)
      Rarchitecture::ApplicationException::VIEW.new(error).handle(self)
    end
  end
end
