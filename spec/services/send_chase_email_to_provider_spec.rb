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
      create(:provider_permissions, provider_id: application_choice.provider.id, provider_user_id: provider_user.id)
      create(:provider_user_notification_preferences, provider_user: provider_user)
      described_class.call(application_choice: application_choice)
    end

    it 'sends a chaser email to the provider' do
      expect(application_choice.chasers_sent.provider_decision_request.count).to eq(1)
    end
  end
end
