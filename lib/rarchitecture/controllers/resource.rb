# frozen_string_literal: true

require "active_support/concern"

module Resource
  extend ActiveSupport::Concern

  included { around_action :catch_halt }

  def service
    raise ApplicationService::NotImplementedError,
          "service not implemented in #{controller_name} controller"
  end

  def record_counts
    @record_counts ||= service.count(**query_params)
  end

  def object_name
    controller_name.singularize
  end

  def model
    inferred_model
  end

  def inferred_model
    return @class_name if defined? @class_name

    parts        = controller_path.split("/")
    modules      = parts[0..-2].map(&:camelize)
    modules.delete("Api")
    model        = parts.last.singularize.camelize
    @class_name  = (modules + [model]).join("::")

    unless class_exists?(@class_name)
      raise ApplicationService::ClassNotFoundError, "Could not find class: #{@class_name}"
    end

    @class_name.constantize
  end

  def controller_key
    parts     = controller_path.split("/")
    modules   = parts[0..-2].map(&:underscore)
    model     = parts.last.singularize.underscore

    (modules + [model]).join("_")
  end

  def permitted_params(method)
    input = input_method(method)
    validate! input

    input.output
  end

  def input_method(method)
    case method
    when :create then creation_input
    when :update then update_input
    end
  end

  def creation_input
    return application_input unless class_exists?("#{model}CreationInput")

    "#{model}CreationInput".constantize.new(modified_request_body)
  end

  def update_input
    return application_input unless class_exists?("#{model}UpdateInput")

    "#{model}UpdateInput".constantize.new(modified_request_body)
  end

  def application_input
    Rarchitecture::ApplicationInput.new(modified_request_body, model: model)
  end

  def output
    return default_output unless class_exists?("#{model}Output")

    "#{model}Output".constantize
  end

  def default_output
    Rarchitecture::ApplicationOutput
  end

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

  def show_options
    { use: :detailed_format }
  end

  # Returns the modified request body, which can be overridden
  # by subclasses to customize request handling.
  def modified_request_body
    request_body
  end

  # Logs an error message and cleaned backtrace for the given resource.
  def log_error(resource)
    Rails.logger.error(
      "resouce_errors => #{log_error_message(resource)}\n" \
      "backtrace => #{::Rails.backtrace_cleaner.clean(resource.backtrace)}\n",
    )
  end

  def log_error_message(resource)
    invalid_class = "ActiveRecord::RecordInvalid".safe_constantize
    resource = resource.record if invalid_class && resource.is_a?(invalid_class)
    return resource.errors.to_a.first if resource.respond_to?(:errors)

    resource.message
  end

  def class_exists?(class_name)
    klass = Module.const_get(class_name)
    klass.is_a?(Class)
  rescue NameError
    false
  end

  def limit
    (params[:limit] ||= 10).to_i
  end

  def offset
    params[:offset].to_i
  end

  def current_page
    params[:page].to_i
  end

  def params
    request.params
  end

  def query_params
    @query_params ||= request.query_parameters.symbolize_keys
  end

  def request_body
    @request_body ||=
      request.request_parameters
             .symbolize_keys
             .except(controller_name.singularize.to_sym)
             .except(:authenticity_token)
             .except(:_method)
  end

  def halt!(*_)
    throw(:halt_controller)
  end

  def catch_halt(&)
    catch(:halt_controller, &)
  end
end
