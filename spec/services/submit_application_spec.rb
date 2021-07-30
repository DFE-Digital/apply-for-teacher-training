require 'rails_helper'

RSpec.describe SubmitApplication do
  describe '#call' do
    it 'updates timestamps relevant to submitting an application' do
      Timecop.freeze(Time.zone.local(0)) do
        application_form = create(:application_form)

        described_class.new(application_form).call

        expect(application_form.submitted_at).to eq Time.zone.local(0)
      end
    end

    it 'sends application choices to providers' do
      application_choice_one = create(:application_choice)
      application_choice_two = create(:application_choice)
      application_form = create(
        :application_form,
        application_choices: [application_choice_one, application_choice_two],
      )
      provider_service_double = class_double('SendApplicationToProvider', call: true).as_stubbed_const

      described_class.new(application_form).call

      expect(provider_service_double).to have_received(:call).with(application_choice_one)
      expect(provider_service_double).to have_received(:call).with(application_choice_two)
    end

    it 'sends the candidate an email' do
      application_form = create(:application_form)
      action_mailer_double = instance_double('ActionMailer::MessageDelivery', deliver_later: true)
      candidate_mailer_double = class_double('CandidateMailer', application_submitted: action_mailer_double).as_stubbed_const

      described_class.new(application_form).call

      expect(candidate_mailer_double).to have_received(:application_submitted).with(application_form)
      expect(action_mailer_double).to have_received(:deliver_later)
    end

    context 'when the application has requested references' do
      let(:application_form) { create(:application_form) }
      let!(:requested_reference_1) { create(:reference, :feedback_requested, application_form: application_form) }
      let!(:requested_reference_2) { create(:reference, :feedback_requested, application_form: application_form) }
      let!(:provided_reference) { create(:reference, :feedback_provided, application_form: application_form) }

      it 'cancels them' do
        described_class.new(application_form).call

        expect(requested_reference_1.reload).to be_cancelled
        expect(requested_reference_2.reload).to be_cancelled
        expect(provided_reference.reload).to be_feedback_provided
      end
    end

    context 'when the application is apply_2' do
      let(:application_form) { create(:application_form, phase: :apply_2) }

      it 'sends the candidate an apply_2 email' do
        action_mailer_double = instance_double('ActionMailer::MessageDelivery', deliver_later: true)
        candidate_mailer_double = class_double('CandidateMailer', application_submitted_apply_again: action_mailer_double).as_stubbed_const

        described_class.new(application_form).call

        expect(candidate_mailer_double).to have_received(:application_submitted_apply_again).with(application_form)
        expect(action_mailer_double).to have_received(:deliver_later)
      end
    end
  end
end
