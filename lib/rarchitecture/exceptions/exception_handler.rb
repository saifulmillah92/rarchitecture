# frozen_string_literal: true

module ExceptionHandler
  def handler
    handler = @object.class.name.underscore.parameterize.underscore
    handler = handler.gsub!("rarchitecture_", "") if handler.include?("rarchitecture_")
    handler = :exception unless respond_to?(handler, true)

    handler
  end

  def backtrace
    return unless @object.respond_to?(:backtrace)

    options[:debug] && @object.backtrace &&
      ::Rails.backtrace_cleaner.clean(@object.backtrace)
  end

  def set_error(status, message)
    options[:status] = status
    @message = message
  end

  def active_record_invalid_foreign_key(_error)
    message = "This record cannot be deleted because it is still referenced by another resource."
    set_error 422, message
  end

  def active_record_not_null_violation(error)
    column =
      begin
        error.message.match(/column "(.*)"/)[1]
      rescue StandardError
        "field"
      end
    message = "The #{column} cannot be blank. Please provide a value."

    set_error(400, message)
  end

  def active_record_record_invalid(error)
    if error.respond_to?(:record)
      set_error 422, error.record.errors.to_a.first
    else
      set_error 422, error.message
    end
  end

  def action_dispatch_params_parser_parse_error(err)
    set_error 400, "There was a problem in the JSON you submitted: #{err}"
  end

  def argument_error(err)                         = set_error 422, err.message
  def active_model_strict_validation_failed(err)  = set_error 422, err.message
  def active_model_unknown_attribute_error(err)   = set_error 422, err.message

  def action_controller_parameter_missing(err)    = set_error 422, err.message
  def action_controller_routing_error(err)        = set_error 404, err.message
  def action_controller_method_not_allowed(_err)  = set_error 403, "Request not allowed"
  def action_controller_invalid_resource(err)     = set_error 422, err.message

  def active_record_unknown_attribute_error(err)  = set_error 422, err.message
  def active_record_statement_invalid(err)        = set_error 404, err.message
  def active_record_record_not_found(err)         = set_error 404, err.message
  def active_record_record_not_unique(err)        = set_error 422, err.message
  def active_record_delete_restriction_error(err) = set_error 422, err.message

  def application_record_invalid(err)             = set_error 422, err.message
  def application_record_not_allowed(err)         = set_error 403, err.message
  def application_record_not_found(err)           = set_error 404, err.message

  def application_service_invalid(err)            = set_error 422, err.message
  def application_service_class_not_found(err)    = set_error 400, err.message
  def application_service_not_implemented_error(err) = set_error 400, err.message
end
