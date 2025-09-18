require 'jwt'

class InviteProviderUser
  DSI_JWT_HMAC = 'HS256'.freeze

  def initialize(provider_user:)
    @provider_user = provider_user
    @dsi_api_url = ENV.fetch('DSI_API_URL')
    @dsi_api_secret = ENV.fetch('DSI_API_SECRET')
  end

  def call!
    lookup_provider_user
    invite_user_to_dfe_sign_in
  end

  def dfe_invite_url
    "#{@dsi_api_url}/services/apply/invitations"
  end

private

  def invite_user_to_dfe_sign_in
    jwt_payload = { iss: 'apply', aud: 'signin.education.gov.uk' }
    token = JWT.encode jwt_payload, @dsi_api_secret, DSI_JWT_HMAC
    auth_string = "Bearer #{token}"
    request_params = {
      sourceId: @provider_user.id,
      given_name: @provider_user.first_name,
      family_name: @provider_user.last_name,
      email: @provider_user.email_address,
      userRedirect: Rails.application.routes.url_helpers.provider_interface_url,
      inviteBodyOverride: 'You can now start managing teacher training applications. You need to create a DfE Sign-in account to do this.',
    }

    response = HTTP.auth(auth_string).post dfe_invite_url, json: request_params
    raise DfeSignInAPIError, response unless response.status.success?
  end

  def lookup_provider_user
    if @provider_user.is_a?(String)
      @provider_user = ProviderUser.find_by!(email_address: @provider_user.downcase)
    end
  end
end

class DfeSignInAPIError < StandardError
  attr_reader :response

  def initialize(response = nil)
    @response = response
    msg = response ? response.status.to_s : 'No response'
    super(msg)
  end

  def errors
    JSON.parse(response.body)['errors']
  rescue StandardError
    []
  end
end
