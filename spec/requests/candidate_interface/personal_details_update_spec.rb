require 'rails_helper'

RSpec.describe 'Candidate interface - personal details', type: :request do
  it 'updates the personal details on the application form' do
    magic_link_token = MagicLinkToken.new
    candidate = create(
      :candidate,
      magic_link_token: magic_link_token.encrypted,
      magic_link_token_sent_at: Time.now,
    )

    valid_attributes = {
      first_name: 'Bob',
      last_name: 'Smith',
      english_main_language: 'yes',
      first_nationality: 'British',
      'date_of_birth(1i)': '2000',
      'date_of_birth(2i)': '1',
      'date_of_birth(3i)': '1',
    }

    expect {
      post candidate_interface_personal_details_update_url(
        token: magic_link_token.raw,
        candidate_interface_personal_details_form: valid_attributes,
      )
    }.to(change { candidate.current_application.audits.count })

    expect(response).to have_http_status(200)
    expect(candidate.current_application.audits.last.user).to eq candidate
  end
end
