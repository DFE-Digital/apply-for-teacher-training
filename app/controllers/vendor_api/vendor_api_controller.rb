module VendorApi
  class VendorApiController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :application_not_found
    rescue_from ActionController::ParameterMissing, with: :parameter_missing

    before_action :set_cors_headers

    def application_not_found(_e)
      render json: {
        errors: [{ error: 'NotFound', message: "Could not find an application with ID #{params[:application_id]}" }],
      }, status: 404
    end

    def parameter_missing(e)
      render json: { errors: [{ error: 'ParameterMissing', message: e }] }, status: 422
    end

  private

    def set_cors_headers
      headers['Access-Control-Allow-Origin'] = '*'
    end
  end
end
