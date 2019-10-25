require 'rails_helper'

RSpec.describe 'Vendor API - audit trail', type: :request do
  include VendorApiSpecHelpers
  include CourseOptionHelpers

  it 'updates the audit trail with the correct attribution when successfully rejected an application' do
    application_choice = create_application_choice_for_currently_authenticated_provider(status: 'application_complete')
    request_body = {
      "data": {
        "reason": 'Does not meet minimum GCSE requirements',
      },
    }

    expect {
      post_api_request "/api/v1/applications/#{application_choice.id}/reject", params: request_body
    }.to(change { application_choice.audits.count })
    expect(application_choice.audits.last.user).to be_present
    expect(application_choice.audits.last.user.full_name).to eq(
      VendorApiSpecHelpers::VALID_METADATA[:attribution][:full_name],
    )
    expect(application_choice.audits.last.user.email_address).to eq(
      VendorApiSpecHelpers::VALID_METADATA[:attribution][:email],
    )
    expect(application_choice.audits.last.user.user_id).to eq(
      VendorApiSpecHelpers::VALID_METADATA[:attribution][:user_id],
    )
  end
end
