require 'rails_helper'

RSpec.describe SubmitApplication do
  describe 'Submit an application' do
    let(:application_form) { create(:application_form) }

    before do
      create(:application_choice, application_form: application_form, status: 'unsubmitted')
      create(:application_choice, application_form: application_form, status: 'unsubmitted')
    end

    it 'updates the application to Submitted' do
      SubmitApplication.new(application_form).call
      expect(application_form.application_choices[0]).to be_awaiting_references
      expect(application_form.application_choices[1]).to be_awaiting_references
    end

    it 'sets application_form.submitted_at' do
      Timecop.freeze(Time.zone.local(2019, 11, 11, 15, 0, 0)) do
        expected_edit_by = Time.zone.local(2019, 11, 18).end_of_day # business days
        SubmitApplication.new(application_form).call

        expect(application_form.submitted_at).to eq Time.zone.now
        expect(application_form.application_choices[0].edit_by).to eq expected_edit_by
        expect(application_form.application_choices[1].edit_by).to eq expected_edit_by
      end
    end

    it 'sends Slack notifications' do
      allow(SlackNotificationWorker).to receive(:perform_async)
      SubmitApplication.new(application_form).call
      expect(SlackNotificationWorker).to have_received(:perform_async).once # per application_form, not application_choices
    end

    context 'when running in a provider sandbox' do
      around do |example|
        ClimateControl.modify(SANDBOX: 'true') do
          example.run
        end
      end

      it 'sets the edit_by timestamp to now and pushes the status on to `awaiting_provider_decision`' do
        now = Time.zone.local(2019, 11, 11, 15, 0, 0)
        Timecop.freeze(now) do
          SubmitApplication.new(application_form).call

          expect(application_form.submitted_at).to eq now
          expect(application_form.application_choices[0].edit_by).to eq now
          expect(application_form.application_choices[1].edit_by).to eq now
        end
      end
    end
  end
end
