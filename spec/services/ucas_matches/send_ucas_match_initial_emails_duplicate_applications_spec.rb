require 'rails_helper'

RSpec.describe UCASMatches::SendUCASMatchInitialEmailsDuplicateApplications do
  describe '#call' do
    let(:course) { create(:course) }
    let(:candidate) { create(:candidate) }
    let(:course_option) { create(:course_option, course: course) }
    let(:application_choice) { create(:application_choice, course_option: course_option) }
    let!(:application_form) { create(:completed_application_form, candidate_id: candidate.id, application_choices: [application_choice]) }
    let(:ucas_match) { create(:ucas_match, application_form: application_form, scheme: %w[B]) }
    let(:provider_user) { create(:provider_user) }
    let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    context 'when the application has a ucas_match' do
      describe 'when initial emails have not been sent' do
        let(:ucas_match) { create(:ucas_match, action_taken: 'initial_emails_sent', candidate: candidate) }

        it 'when the emails have already been sent it throws an exception' do
          expect { described_class.new(ucas_match).call }.to raise_error("Initial emails for UCAS match ##{ucas_match.id} were already sent")
        end

        it 'when no application_choices_for_same_course_on_both_services are present' do
          weird_match = build_stubbed(:ucas_match)
          allow(weird_match).to receive(:application_choices_for_same_course_on_both_services).and_return([])

          expect { described_class.new(weird_match).call }.to raise_error("No application choices found for UCAS match ##{weird_match.id}")
        end
      end

      describe 'when the initial emails have not been sent already' do
        before do
          create(:provider_permissions, provider_id: course.provider.id, provider_user_id: provider_user.id)
          allow(CandidateMailer).to receive(:ucas_match_initial_email_duplicate_applications).and_return(mail)
          allow(ProviderMailer).to receive(:ucas_match_initial_email_duplicate_applications).and_return(mail)
          described_class.new(ucas_match).call
        end

        it 'sends the candidate the initial ucas_match email' do
          expect(CandidateMailer).to have_received(:ucas_match_initial_email_duplicate_applications).with(application_choice)
        end

        it 'sends the provider the ucas_match email' do
          expect(ProviderMailer).to have_received(:ucas_match_initial_email_duplicate_applications).with(provider_user, application_choice)
        end
      end
    end
  end
end
