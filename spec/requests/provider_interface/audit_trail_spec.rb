require 'rails_helper'

RSpec.describe 'Provider interface - audit trail', type: :request do
  def create_application
    application_form = create :application_form
    application_choice = create(
      :application_choice,
      application_form: application_form,
      status: 'awaiting_provider_decision',
    )
    provider = create :provider, code: 'ABC'
    application_choice.course.update(accrediting_provider: provider)
    application_choice
  end

  before do
    allow(ProviderUser).to receive(:load_from_session)
      .and_return(
        ProviderUser.new(
          email_address: 'alice@example.com',
          dfe_sign_in_uid: 'ABC',
        ),
    )

    allow(Rails.application.config).to receive(:provider_permissions).and_return(ABC: 'ABC')
  end

  it 'creates audit records attributed to the authenticated provider' do
    application_choice = create_application
    expect {
      post provider_interface_application_choice_create_offer_path(
        application_choice_id: application_choice.id,
      ), params: { offer_conditions: '["must be clever"]' }
    }.to(change { application_choice.audits.count })

    expect(application_choice.audits.last.username).to eq 'alice@example.com (Provider)'
  end
end
