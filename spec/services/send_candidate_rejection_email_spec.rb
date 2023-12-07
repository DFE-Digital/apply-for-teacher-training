require 'rails_helper'

RSpec.describe SendCandidateRejectionEmail do
  describe '#call' do
    let(:application_form) { build(:completed_application_form) }
    let(:application_choice) { create(:application_choice, status: :rejected, application_form:) }
    let(:application_choice_with_offer) { create(:application_choice, :offered, application_form:) }
    let(:application_choice_awaiting_decision) { create(:application_choice, status: :awaiting_provider_decision, application_form:) }
    let(:application_choice_with_interview) { create(:application_choice, status: :interviewing, application_form:) }
    let(:application_choice_withdrawn) { create(:application_choice, status: :withdrawn, application_form:) }
    let(:application_choice_not_sent) { create(:application_choice, status: :application_not_sent, application_form:) }
    let(:application_choice_declined) { create(:application_choice, status: :declined, application_form:) }
    let(:application_choice_offer_withdrawn) { create(:application_choice, status: :offer_withdrawn, application_form:) }
    let(:application_choice_offer_deferred) { create(:application_choice, status: :offer_deferred, application_form:) }
    let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    context 'when an application choice is rejected and it is not continous applications', continuous_applications: false do
      describe 'when all application choices have been rejected' do
        before do
          allow(CandidateMailer).to receive(:application_rejected_all_applications_rejected).and_return(mail)
          described_class.new(application_choice:).call
        end

        it 'the all_applications_rejected email is sent to the candidate' do
          expect(CandidateMailer).to have_received(:application_rejected_all_applications_rejected).with(application_choice)
        end
      end

      describe 'when all remaining applications are with offer' do
        before do
          application_choice_with_offer

          allow(CandidateMailer).to receive(:application_rejected_offers_only).and_return(mail)
          described_class.new(application_choice:).call
        end

        it 'the application_rejected_offers_only email is sent to the candidate' do
          expect(CandidateMailer).to have_received(:application_rejected_offers_only).with(application_choice)
        end
      end

      describe 'when applications are withdrawn and another is rejected' do
        before do
          application_choice_withdrawn
          application_choice

          allow(CandidateMailer).to receive(:application_rejected_all_applications_rejected).and_return(mail)
          described_class.new(application_choice:).call
        end

        it 'sends the all_applications_rejected email to the candidate' do
          expect(CandidateMailer).to have_received(:application_rejected_all_applications_rejected).with(application_choice)
        end
      end

      describe 'when applications are declined and another is rejected' do
        before do
          application_choice_declined
          application_choice

          allow(CandidateMailer).to receive(:application_rejected_all_applications_rejected).and_return(mail)
          described_class.new(application_choice:).call
        end

        it 'sends the all_applications_rejected email to the candidate' do
          expect(CandidateMailer).to have_received(:application_rejected_all_applications_rejected).with(application_choice)
        end
      end

      describe 'applications have had offers withdrawn and another is rejected' do
        before do
          application_choice_offer_withdrawn
          application_choice

          allow(CandidateMailer).to receive(:application_rejected_all_applications_rejected).and_return(mail)
          described_class.new(application_choice:).call
        end

        it 'sends the all_applications_rejected email to the candidate' do
          expect(CandidateMailer).to have_received(:application_rejected_all_applications_rejected).with(application_choice)
        end
      end

      describe 'applications have had offers deferred and another is rejected' do
        before do
          application_choice_offer_deferred
          application_choice

          allow(CandidateMailer).to receive(:application_rejected_all_applications_rejected).and_return(mail)
          described_class.new(application_choice:).call
        end

        it 'sends the all_applications_rejected email to the candidate' do
          expect(CandidateMailer).to have_received(:application_rejected_all_applications_rejected).with(application_choice)
        end
      end
    end

    context 'when an application is rejected and it is continuous applications', :continuous_applications do
      before do
        allow(CandidateMailer).to receive(:application_rejected).and_return(mail)
        described_class.new(application_choice:).call
      end

      it 'the applications_rejected email is sent to the candidate' do
        expect(CandidateMailer).to have_received(:application_rejected).with(application_choice)
      end
    end
  end
end
