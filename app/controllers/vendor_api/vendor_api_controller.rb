module VendorApi
  class VendorApiController < ActionController::API
    before_action :set_cors_headers

  private

    def set_cors_headers
      headers['Access-Control-Allow-Origin'] = '*'
    end

    def application_not_found(_e)
      render json: {
        errors: [{ error: 'NotFound', message: "Could not find an application with ID #{params[:application_id]}" }],
      }, status: 404
    end
  end
end
