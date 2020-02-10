require 'rails_helper'

RSpec.describe SendChaseEmailToProvider do
  describe '#call' do
    let(:application_choice) do
      create(:submitted_application_choice,
             application_form: create(:completed_application_form),
             status: 'awaiting_provider_decision')
    end
    let(:provider_user) { create(:provider_user) }
    let(:provider_id) { application_choice.provider.id }

    before do
      create(:provider_users_provider, provider_id: application_choice.provider.id, provider_user_id: provider_user.id)
      described_class.call(application_choice: application_choice)
    end

    it 'sends a chaser email to the provider' do
      expect(application_choice.chasers_sent.provider_decision_request.count).to eq(1)
    end

    it 'audits the chase emails', with_audited: true do
      expected_comment =
        "Chase emails have been sent to the provider #{provider_user.email_address}" +
        " because the application for #{application_choice.course.name_and_code} is close to its RBD date."
      expect(application_choice.application_form.audits.last.comment).to eq(expected_comment)
    end
  end
end
