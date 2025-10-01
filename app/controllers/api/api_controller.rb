module Api
  class ApiController < ActionController::Base
    include ActionController::MimeResponds
    before_action :only_accept_json_request

    rescue_from ActiveRecord::RecordNotFound do |e|
      render json: { error: e.message }, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity 
    end

    rescue_from ArgumentError do |e|
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def only_accept_json_request
      return if request.format.json?

      raise ActionController::RoutingError, 'Not supported format'
    end
  end
end