module VendorAPI
  class VendorAPIController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods
    include RequestQueryParams
    include RemoveBrowserOnlyHeaders
    include Versioning

    rescue_from ActiveRecord::RecordNotFound, with: :application_not_found
    rescue_from ActionController::ParameterMissing, with: :parameter_missing
    rescue_from ParameterInvalid, with: :parameter_invalid

    # Makes PG::QueryCanceled statement timeout errors appear in Skylight
    # against the controller action that triggered them
    # instead of bundling them with every other ErrorsController#internal_server_error
    rescue_from ActiveRecord::QueryCanceled, with: :statement_timeout

    before_action :set_cors_headers
    before_action :require_valid_api_token!
    before_action :set_user_context

    def audit_user
      return unless @metadata

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
      }, status: :not_found
    end

    def parameter_missing(e)
      error_message = e.message.split("\n").first
      render json: { errors: [{ error: 'ParameterMissing', message: error_message }] }, status: :unprocessable_entity
    end

    def parameter_invalid(e)
      render json: { errors: [{ error: 'ParameterInvalid', message: e }] }, status: :unprocessable_entity
    end

    def statement_timeout
      render json: {
        errors: [
          {
            error: 'InternalServerError',
            message: 'The server encountered an unexpected condition that prevented it from fulfilling the request',
          },
        ],
      }, status: :internal_server_error
    end

    def set_cors_headers
      headers['Access-Control-Allow-Origin'] = '*'
    end

    def require_valid_api_token!
      if valid_api_token?
        @current_vendor_api_token.update!(
          last_used_at: Time.zone.now,
        )
      else
        unauthorized_response = {
          errors: [
            {
              error: 'Unauthorized',
              message: 'Please provide a valid authentication token',
            },
          ],
        }

        render json: unauthorized_response, status: :unauthorized
      end
    end

    def valid_api_token?
      authenticate_with_http_token do |unhashed_token|
        @current_vendor_api_token = VendorAPIToken.find_by_unhashed_token(unhashed_token)
      end
    end

    def current_provider
      @current_provider ||= @current_vendor_api_token&.provider
    end

    def set_user_context
      Sentry.set_user(id: "api_token_#{@current_vendor_api_token&.id}")
    end

    def append_info_to_payload(payload)
      super

      user_info = {
        vendor_api_token_id: @current_vendor_api_token&.id,
        provider_id: current_provider&.id,
      }

      payload.merge!(user_info)
      payload.merge!(query_params: request_query_params)
    end

    def validate_metadata!
      @metadata = Metadata.new(params[:meta])

      if @metadata.invalid?
        render_validation_errors(@metadata.errors)
      end
    end
  end
end
