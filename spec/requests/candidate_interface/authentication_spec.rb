require 'rails_helper'

RSpec.describe 'Authentication for candidates' do
  it 'redirects the user on root path' do
    get root_path
    expect(response).to redirect_to(candidate_interface_create_account_or_sign_in_path)
  end

  it 'redirects the user if the token is invalid' do
    get candidate_interface_continuous_applications_details_path(token: '123')

    expect(response).to have_http_status(:found)
  end

  it 'redirects the user if the token is missing from the URL' do
    get candidate_interface_continuous_applications_details_path

    expect(response).to have_http_status(:found)
  end

  it 'redirects the user if the token is expired' do
    magic_link_token = MagicLinkToken.new
    create(:candidate, magic_link_token: magic_link_token.encrypted, magic_link_token_sent_at: 2.days.ago)

    get candidate_interface_continuous_applications_details_path(token: magic_link_token.raw)

    expect(response).to have_http_status(:found)
  end
end
