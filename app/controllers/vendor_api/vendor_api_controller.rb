module VendorAPI
  class VendorAPIController < ApplicationAPIController
    include ActionController::HttpAuthentication::Token::ControllerMethods
    include RequestQueryParams
    include RemoveBrowserOnlyHeaders
    include Versioning
    include APIValidationsAndErrorHandling

    before_action :set_cors_headers
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

    def set_cors_headers
      headers['Access-Control-Allow-Origin'] = '*'
    end

    def current_provider
      @current_provider ||= @current_vendor_api_token&.provider
    end

    # for dfe-analytics
    alias current_user current_provider

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
  end
end
