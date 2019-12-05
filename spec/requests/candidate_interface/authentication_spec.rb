require 'rails_helper'

RSpec.describe 'Authentication for candidates', type: :request do
  it 'redirects the user if the token is invalid' do
    get candidate_interface_application_form_url(token: '123')

    # TODO: add a better check once we have implemented error messages
    expect(response).to have_http_status(302)
  end

  it 'redirects the user if the token is missing from the URL' do
    get candidate_interface_application_form_url

    # TODO: add a better check once we have implemented error messages
    expect(response).to have_http_status(302)
  end

  it 'redirects the user if the token is expired' do
    magic_link_token = MagicLinkToken.new
    create(:candidate, magic_link_token: magic_link_token.encrypted, magic_link_token_sent_at: Time.now - 2.days)

    get candidate_interface_application_form_url(token: magic_link_token.raw)

    # TODO: add a better check once we have implemented error messages
    expect(response).to have_http_status(302)
  end
end
