require 'jwt'

class InviteProviderUser
  def initialize(provider_user_form:)
    @provider_user_form = provider_user_form
  end

  def call
    ActiveRecord::Base.transaction do
      if @provider_user_form.save
        invite_user_to_dfe_sign_in

        # TODO: send welcome/invitation email
        true
      end
    end
  rescue DfeSignInApiError => e
    e.errors.each { |error| @provider_user_form.errors.add(:base, error) }
    false
  end

  def dfe_invite_url
    baseurl = ENV.fetch('DSI_API_URL')
    if baseurl.present?
      "#{baseurl}/services/apply/invitations"
    end
  end

  def invite_user_to_dfe_sign_in
    return unless FeatureFlag.active?('send_dfe_sign_in_invitations')

    jwt_payload = { iss: 'apply', aud: 'signin.education.gov.uk' }
    token = JWT.encode jwt_payload, ENV['DSI_API_SECRET'], 'HS256'
    auth_string = "Bearer #{token}"

    request_params = {
      sourceId: @provider_user_form.provider_user.id,
      given_name: @provider_user_form.first_name,
      family_name: @provider_user_form.last_name,
      email: @provider_user_form.email_address,
      userRedirect: Rails.application.routes.url_helpers.provider_interface_url,
    }

    response = HTTP.auth(auth_string).post dfe_invite_url, json: request_params
    raise DfeSignInApiError.new(response) unless response.status.success?
  end
end

class DfeSignInApiError < StandardError
  attr_reader :response

  def initialize(response = nil)
    @response = response
    msg = response ? response.status.to_s : 'No response'
    super(msg)
  end

  def errors
    JSON.parse(response.body)['errors'] rescue []
  end
end
