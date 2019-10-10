module VendorApi
  class VendorApiController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :application_not_found
    rescue_from ActionController::ParameterMissing, with: :parameter_missing

    before_action :set_cors_headers
    before_action :require_valid_api_token!

  private

    def application_not_found(_e)
      render json: {
        errors: [{ error: 'NotFound', message: "Could not find an application with ID #{params[:application_id]}" }],
      }, status: 404
    end

    def parameter_missing(e)
      render json: { errors: [{ error: 'ParameterMissing', message: e }] }, status: 422
    end

    def set_cors_headers
      headers['Access-Control-Allow-Origin'] = '*'
    end

    def require_valid_api_token!
      return if valid_api_token?

      unauthorized_response = {
        errors: [
          {
            error: 'Unauthorized',
            message: 'Please provide a valid authentication token',
          },
        ],
      }

      render json: unauthorized_response, status: 401
    end

    def valid_api_token?
      return unless request.headers['Authorization']

      unhashed_token = request.headers['Authorization'].split(' ').last
      VendorApiToken.find_by_unhashed_token(unhashed_token)
    end
  end
end
