require 'rails_helper'

RSpec.describe 'Provider interface - audit trail', type: :request, with_audited: true do
  include CourseOptionHelpers

  it 'creates audit records attributed to the authenticated provider' do
    provider_user = create(:provider_user, :with_provider, :with_make_decisions)
    course_option = course_option_for_provider(provider: provider_user.providers.first)
    application_choice = create(:application_choice, :with_offer, course_option: course_option)

    allow(ProviderUser).to receive(:load_from_session)
      .and_return(
        ProviderUser.new(
          id: provider_user.id,
          providers: provider_user.providers,
        ),
      )

    expect {
      post provider_interface_application_choice_withdraw_offer_path(
        application_choice_id: application_choice.id,
        course_option_id: course_option.id,
      ), params: { withdraw_offer: { offer_withdrawal_reason: 'All spots taken' } }
    }.to(change { application_choice.audits.count })

    expect(application_choice.audits.last.user_id).to eq provider_user.id
    expect(application_choice.audits.last.user_type).to eq 'ProviderUser'
  end
end
