require 'rails_helper'

RSpec.describe SubmitApplicationChoice do
  let(:current_date) { Time.zone.local(2020, 3, 1) }
  let(:application_form) { create(:application_form, submitted_at: Time.zone.now) }
  let(:application_choice) { create(:application_choice, application_form: application_form, status: 'unsubmitted') }

  around do |example|
    Timecop.freeze(current_date) do
      example.run
    end
  end

  describe 'Submit an application choice', sandbox: false do
    it 'updates the application choice to Awaiting References' do
      SubmitApplicationChoice.new(application_choice).call

      expect(application_choice).to be_awaiting_references
    end
  end

  describe 'Submit an application choice to the provider immediately' do
    let(:submit_application_choice) do
      SubmitApplicationChoice.new(
        application_choice,
        send_to_provider_immediately: send_to_provider_immediately,
      ).call
    end

    context 'and enough references have been provided' do
      let(:send_to_provider_immediately) { true }

      it 'updates the application choice state to Application Complete' do
        submit_application_choice

        expect(application_choice).to be_awaiting_provider_decision
      end
    end

    context 'and not enough references have been provided' do
      let(:send_to_provider_immediately) { false }

      it 'updates the application choice to Awaiting References' do
        submit_application_choice

        expect(application_choice).to be_awaiting_references
      end
    end
  end
end
