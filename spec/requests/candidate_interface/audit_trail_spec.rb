require 'rails_helper'

RSpec.describe 'Candidate interface - audit trail', with_audited: true do
  include Devise::Test::IntegrationHelpers

  def create_candidate(magic_link_token)
    create(
      :candidate,
      magic_link_token: magic_link_token.encrypted,
      magic_link_token_sent_at: Time.zone.now,
    )
  end

  def valid_attributes
    {
      first_name: 'Bob',
      last_name: 'Smith',
      english_main_language: 'yes',
      first_nationality: 'British',
      'date_of_birth(1i)': '2000',
      'date_of_birth(2i)': '1',
      'date_of_birth(3i)': '1',
    }
  end

  it 'creates audit records attributed to the authenticated candidate' do
    magic_link_token = MagicLinkToken.new
    candidate = create_candidate(magic_link_token)
    sign_in candidate

    expect {
      patch candidate_interface_name_and_dob_url(
        candidate_interface_personal_details_form: valid_attributes,
      )
    }.to(change { candidate.current_application.audits.count })

    expect(candidate.current_application.audits.last.user).to eq candidate
  end
end
