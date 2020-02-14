require 'rails_helper'

RSpec.describe SendCandidateRejectionEmail do
  describe '#call' do
    let(:application_form) { create(:completed_application_form) }
    let(:application_choice) {  create(:application_choice, status: :rejected, application_form: application_form) }

    context 'when the candidate has had all of their application choices rejected' do
      before do
        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(CandidateMailer).to receive(:all_application_choices_rejected).and_return(mail)
      end

      it 'sends them the all applications rejected email' do
        described_class.call(application_choice: application_choice)
        expect(CandidateMailer).to have_received(:all_application_choices_rejected).with(application_choice)
      end

      it 'audits the rejection email', with_audited: true do
        expected_comment =
          "New rejection email sent to candidate #{application_choice.application_form.candidate.email_address} for " +
          "#{application_choice.course_option.course.name_and_code} at #{application_choice.course_option.course.provider.name}."

        described_class.call(application_choice: application_choice)

        expect(application_choice.application_form.audits.last.comment).to eq(expected_comment)
      end
    end
  end
end
