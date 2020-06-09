require 'rails_helper'

RSpec.describe 'Provider interface - audit trail', type: :request, with_audited: true do
  include CourseOptionHelpers

  def set_provider_permission(application_choice)
    allow(ProviderUser).to receive(:load_from_session)
      .and_return(
        ProviderUser.new(
          id: 123,
          email_address: 'alice@example.com',
          dfe_sign_in_uid: 'ABCDEF',
          providers: [application_choice.course.provider],
        ),
      )
  end

  it 'creates audit records attributed to the authenticated provider' do
    application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
    )
    set_provider_permission(application_choice)

    expect {
      post provider_interface_application_choice_create_offer_path(
        application_choice_id: application_choice.id,
        course_option_id: course_option_for_provider(provider: application_choice.provider).id,
      ), params: { offer_conditions: '["must be clever"]' }
    }.to(change { application_choice.audits.count })

    expect(application_choice.audits.last.user_id).to eq 123
    expect(application_choice.audits.last.user_type).to eq 'ProviderUser'
  end
end
