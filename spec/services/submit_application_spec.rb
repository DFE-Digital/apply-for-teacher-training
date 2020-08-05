require 'rails_helper'

RSpec.describe SubmitApplication do
  describe 'Submit an application', sandbox: false do
    let(:current_date) { Time.zone.local(2019, 11, 11, 15, 0, 0) }

    def create_application_form
      application_form = create(:application_form, submitted_at: current_date)
      create(:application_choice, application_form: application_form, status: 'unsubmitted')
      create(:application_choice, application_form: application_form, status: 'unsubmitted')
      application_form
    end

    it 'sets application_form.submitted_at and edit_by on the application foorm and choices' do
      application_form = create_application_form
      Timecop.freeze(Time.zone.local(2019, 11, 11, 15, 0, 0)) do
        expected_edit_by = Time.zone.local(2019, 11, 18).end_of_day # business days
        SubmitApplication.new(application_form).call

        expect(application_form.submitted_at).to eq Time.zone.now
        expect(application_form.edit_by).to eq expected_edit_by

        expect(application_form.application_choices[0].status).to eq 'awaiting_references'
        expect(application_form.application_choices[1].status).to eq 'awaiting_references'
      end
    end

    it 'sends Slack notifications' do
      application_form = create_application_form
      allow(SlackNotificationWorker).to receive(:perform_async)
      SubmitApplication.new(application_form).call
      expect(SlackNotificationWorker).to have_received(:perform_async).once # per application_form, not application_choices
    end

    it 'sends email to referees' do
      mailer = instance_double(ActionMailer::MessageDelivery, deliver_later: nil)
      allow(RefereeMailer).to receive(:reference_request_email).and_return(mailer)
      application_form = create_application_form
      create(:reference, application_form: application_form)
      create(:reference, application_form: application_form)
      SubmitApplication.new(application_form).call
      expect(mailer).to have_received(:deliver_later).twice
    end

    context 'when running in a provider sandbox', sandbox: true do
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

    context 'when application is in Apply Again' do
      it 'progresses to `awaiting_provider_decision` if all references are in' do
        original_application_form = create_application_form

        original_application_form.application_references << build(:reference, email_address: 'bob@example.com', feedback_status: :feedback_provided)
        original_application_form.application_references << build(:reference, email_address: 'alice@example.com', feedback_status: :feedback_provided)
        original_application_form.application_references.reload

        application_form = DuplicateApplication.new(original_application_form).duplicate
        application_form.application_choices << build(:application_choice, status: :unsubmitted)

        SubmitApplication.new(application_form).call

        application_form.application_choices.reload
        expect(application_form.application_choices[0]).to be_awaiting_provider_decision
      end

      it 'progresses to `awaiting_references` if not all references are in' do
        mailer = instance_double(ActionMailer::MessageDelivery, deliver_later: nil)
        allow(CandidateMailer).to receive(:application_submitted_apply_again).and_return(mailer)

        original_application_form = create_application_form

        original_application_form.application_references << build(:reference, email_address: 'bob@example.com', feedback_status: :feedback_provided)
        original_application_form.application_references << build(:reference, email_address: 'alice@example.com', feedback_status: :not_requested_yet)
        original_application_form.application_references.reload

        application_form = DuplicateApplication.new(original_application_form).duplicate
        application_form.application_choices << build(:application_choice, status: :unsubmitted)

        SubmitApplication.new(application_form).call

        application_form.application_choices.reload
        expect(application_form.application_choices[0]).to be_awaiting_references
        expect(mailer).to have_received(:deliver_later).once
      end
    end
  end
end
