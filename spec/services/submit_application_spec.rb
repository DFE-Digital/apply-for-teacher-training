require 'rails_helper'

RSpec.describe SubmitApplication do
  describe 'Submit an application', sandbox: false do
    def create_application_form
      application_form = create(:application_form)
      create(:application_choice, application_form: application_form, status: 'unsubmitted')
      create(:application_choice, application_form: application_form, status: 'unsubmitted')
      application_form
    end

    it 'updates the application to Submitted' do
      application_form = create_application_form
      SubmitApplication.new(application_form).call
      expect(application_form.application_choices[0]).to be_awaiting_references
      expect(application_form.application_choices[1]).to be_awaiting_references
    end

    it 'sets application_form.submitted_at' do
      application_form = create_application_form
      Timecop.freeze(Time.zone.local(2019, 11, 11, 15, 0, 0)) do
        expected_edit_by = Time.zone.local(2019, 11, 18).end_of_day # business days
        SubmitApplication.new(application_form).call

        expect(application_form.submitted_at).to eq Time.zone.now
        expect(application_form.application_choices[0].edit_by).to eq expected_edit_by
        expect(application_form.application_choices[1].edit_by).to eq expected_edit_by
      end
    end

    it 'sends Slack notifications' do
      application_form = create_application_form
      allow(SlackNotificationWorker).to receive(:perform_async)
      SubmitApplication.new(application_form).call
      expect(SlackNotificationWorker).to have_received(:perform_async).once # per application_form, not application_choices
    end

    context 'when running in a provider sandbox', sandbox: true do
      it 'sets the edit_by timestamp to now' do
        application_form = create_application_form
        now = Time.zone.local(2019, 11, 11, 15, 0, 0)
        Timecop.freeze(now) do
          SubmitApplication.new(application_form).call

          expect(application_form.submitted_at).to eq now
          expect(application_form.application_choices[0].edit_by).to eq now
          expect(application_form.application_choices[1].edit_by).to eq now
        end
      end

      it 'autocompletes references and pushes status to `awaiting_provider_decision`' do
        application_form = create_application_form
        application_form.application_references << build(:reference, email_address: 'refbot1@example.com')
        application_form.application_references << build(:reference, email_address: 'refbot2@example.com')
        application_form.application_references.reload

        SubmitApplication.new(application_form).call

        application_form.application_references.reload.each do |reference|
          expect(reference.feedback).not_to be_nil
          expect(reference.feedback_status).to eq 'feedback_provided'
        end
        application_form.application_choices.reload
        expect(application_form.application_choices[0]).to be_awaiting_provider_decision
        expect(application_form.application_choices[1]).to be_awaiting_provider_decision
      end
    end
  end
end
