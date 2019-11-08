module VendorApi
  class VendorApiController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods
    include LogRequestParams

    rescue_from ActiveRecord::RecordNotFound, with: :application_not_found
    rescue_from ActionController::ParameterMissing, with: :parameter_missing

    before_action :set_cors_headers
    before_action :require_valid_api_token!
    before_action :add_api_key_and_provider_ids_to_log

    def audit_user
      return nil unless @metadata.present?

      @audit_user ||= find_or_create_audit_user
    end

  private

    def find_or_create_audit_user
      vendor_api_user = VendorApiUser.find_or_initialize_by(
        vendor_user_id: @metadata.attribution.user_id,
        vendor_api_token_id: @current_vendor_api_token.id,
      )
      vendor_api_user.email_address = @metadata.attribution.email
      vendor_api_user.full_name = @metadata.attribution.full_name
      vendor_api_user.save!
      vendor_api_user
    end

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
      authenticate_with_http_token do |unhashed_token|
        @current_vendor_api_token = VendorApiToken.find_by_unhashed_token(unhashed_token)
      end
    end

    def current_provider
      @current_provider ||= @current_vendor_api_token.provider
    end

    # controller-specific additional info to include in logstash logs
    def add_api_key_and_provider_ids_to_log
      RequestLocals.store[:vendor_api_token_id] = @current_vendor_api_token.try(:id)
      RequestLocals.store[:provider_id] = current_provider.try(:id) if @current_vendor_api_token
    end

    def validate_metadata!
      @metadata = Metadata.new(params[:meta])

      if @metadata.invalid?
        render_validation_errors(@metadata.errors)
      end
    end
  end
end
