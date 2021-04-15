require 'rails_helper'

RSpec.describe SendCandidateRejectionEmail do
  describe '#call' do
    let(:application_form) { build(:completed_application_form) }
    let(:application_choice) { create(:application_choice, status: :rejected, application_form: application_form) }
    let(:application_choice_with_offer) { create(:application_choice, :with_offer, application_form: application_form) }
    let(:application_choice_awaiting_decision) { create(:application_choice, status: :awaiting_provider_decision, application_form: application_form) }
    let(:application_choice_with_interview) { create(:application_choice, status: :interviewing, application_form: application_form) }
    let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    context 'when an application choice is rejected' do
      describe 'when all application choices have been rejected' do
        before do
          allow(CandidateMailer).to receive(:application_rejected_all_applications_rejected).and_return(mail)
          described_class.new(application_choice: application_choice).call
        end

        it 'the all_applications_rejected email is sent to the candidate' do
          expect(CandidateMailer).to have_received(:application_rejected_all_applications_rejected).with(application_choice)
        end
      end

      describe 'when there are applications both with offer and awaiting decision' do
        before do
          application_choice_with_offer
          application_choice_awaiting_decision

          allow(CandidateMailer).to receive(:application_rejected_one_offer_one_awaiting_decision).and_return(mail)
          described_class.new(application_choice: application_choice).call
        end

        it 'the application_rejected_one_offer_one_awaiting_decision email is sent to the candidate' do
          expect(CandidateMailer).to have_received(:application_rejected_one_offer_one_awaiting_decision).with(application_choice)
        end
      end

      describe 'when there are applications both with offer and interviews' do
        before do
          application_choice_with_offer
          application_choice_with_interview

          allow(CandidateMailer).to receive(:application_rejected_one_offer_one_awaiting_decision).and_return(mail)
          described_class.new(application_choice: application_choice).call
        end

        it 'the application_rejected_one_offer_one_awaiting_decision email is sent to the candidate' do
          expect(CandidateMailer).to have_received(:application_rejected_one_offer_one_awaiting_decision).with(application_choice)
        end
      end

      describe 'when all remaining applications are awaiting decision' do
        before do
          application_choice_awaiting_decision

          allow(CandidateMailer).to receive(:application_rejected_awaiting_decision_only).and_return(mail)
          described_class.new(application_choice: application_choice).call
        end

        it 'the application_rejected_awaiting_decision_only email is sent to the candidate' do
          expect(CandidateMailer).to have_received(:application_rejected_awaiting_decision_only).with(application_choice)
        end
      end

      describe 'when all remaining applications are with offer' do
        before do
          application_choice_with_offer

          allow(CandidateMailer).to receive(:application_rejected_offers_only).and_return(mail)
          described_class.new(application_choice: application_choice).call
        end

        it 'the application_rejected_offers_only email is sent to the candidate' do
          expect(CandidateMailer).to have_received(:application_rejected_offers_only).with(application_choice)
        end
      end
    end
  end
end
