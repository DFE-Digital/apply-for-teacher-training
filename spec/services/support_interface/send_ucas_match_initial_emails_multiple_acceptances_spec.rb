require 'rails_helper'

RSpec.describe SupportInterface::SendUCASMatchInitialEmailsMultipleAcceptances do
  describe '#call' do
    let(:course) { create(:course, recruitment_cycle_year: 2020) }
    let(:candidate) { create(:candidate) }
    let(:course_option) { create(:course_option, course: course) }
    let(:application_choice) { create(:application_choice, course_option: course_option) }
    let(:application_form) { create(:completed_application_form, candidate_id: candidate.id, application_choices: [application_choice]) }
    let(:ucas_match) { create(:ucas_match, recruitment_cycle_year: 2020, candidate: candidate, matching_data: [matching_data]) }
    let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    context 'when the application has been accepted on both apply and ucas' do
      describe 'when initial emails have not been sent' do
        let(:ucas_match) { create(:ucas_match, action_taken: 'initial_emails_sent', candidate: candidate) }

        it 'when the emails have already been sent it throws an exception' do
          expect { described_class.new(ucas_match).call }.to raise_error('UCAS Match initial emails already sent')
        end
      end

      describe 'when the initial emails have not been sent already' do
        let(:matching_data) { { 'Scheme' => 'B', 'Course code' => course.code.to_s, 'Provider code' => course.provider.code.to_s, 'Apply candidate ID' => candidate.id.to_s } }

        before do
          application_form
          allow(CandidateMailer).to receive(:ucas_match_initial_email_multiple_acceptances).and_return(mail)
          described_class.new(ucas_match).call
        end

        it 'sends the candidate the initial ucas_match email for multiple acceptances' do
          expect(CandidateMailer).to have_received(:ucas_match_initial_email_multiple_acceptances).with(ucas_match.candidate)
        end
      end
    end
  end
end
