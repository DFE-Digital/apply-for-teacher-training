require 'rails_helper'

RSpec.describe SendCandidateRejectionEmail do
  describe '#call' do
    let(:application_form) { build(:completed_application_form) }
    let(:application_choice) { create(:application_choice, status: :rejected, application_form: application_form) }

    def expected_audit_comment
      "New rejection email sent to candidate #{application_choice.application_form.candidate.email_address} for " +
        "#{application_choice.course_option.course.name_and_code} at #{application_choice.course_option.course.provider.name}."
    end

    context 'when the candidate has had all of their application choices rejected' do
      before do
        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(CandidateMailer).to receive(:application_rejected_all_rejected).and_return(mail)
        described_class.new(application_choice: application_choice).call
      end

      it 'sends them the all applications rejected email' do
        expect(CandidateMailer).to have_received(:application_rejected_all_rejected).with(application_choice)
      end

      it 'audits the rejection email', with_audited: true do
        expect(application_choice.application_form.audits.last.comment).to eq(expected_audit_comment)
      end
    end

    context 'when the candidate receives a rejection, has pending decisions and no offers' do
      before do
        create(:application_choice, status: :awaiting_provider_decision, application_form: application_form)
        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(CandidateMailer).to receive(:application_rejected_awaiting_decisions).and_return(mail)
        described_class.new(application_choice: application_choice).call
      end

      it 'sends them the awaiting_decisions email' do
        expect(CandidateMailer).to have_received(:application_rejected_awaiting_decisions).with(application_choice)
      end

      it 'audits the rejection email', with_audited: true do
        expect(application_choice.application_form.audits.last.comment).to eq(expected_audit_comment)
      end
    end
  end
end
