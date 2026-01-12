require 'rails_helper'

RSpec.describe 'Provider interface - audit trail', :with_audited do
  include CourseOptionHelpers

  # include Devise::Test::IntegrationHelpers

  it 'creates audit records attributed to the authenticated provider' do
    provider_user = create(:provider_user, :with_provider, :with_make_decisions)
    course_option = course_option_for_provider(provider: provider_user.providers.first)
    application_choice = create(:application_choice, :offered, course_option:)

    allow(ProviderUser).to receive(:load_from_session)
      .and_return(
        provider_user,
      )

    expect {
      post provider_interface_application_choice_withdraw_offer_path(
        application_choice_id: application_choice.id,
        course_option_id: course_option.id,
      ), params: { withdraw_offer: { offer_withdrawal_reason: 'All spots taken' } }
    }.to(change { application_choice.reload.audits.count })

    expect(application_choice.audits.last.user_id).to eq provider_user.id
    expect(application_choice.audits.last.user_type).to eq 'ProviderUser'
  end
end
