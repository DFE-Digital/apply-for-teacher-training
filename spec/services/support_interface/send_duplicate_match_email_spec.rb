require 'rails_helper'

RSpec.describe SupportInterface::SendDuplicateMatchEmail do
  let(:duplicate_match) { create(:duplicate_match) }
  let(:candidate) { duplicate_match.candidates.first }

  describe '#call' do
    before do
      build(
        :application_form,
        candidate: candidate,
      )

      mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(CandidateMailer).to receive(:duplicate_match_email).and_return(mail)
    end

    it 'sends an email to the candidate' do
      described_class.new(candidate).call
      expect(CandidateMailer).to have_received(:duplicate_match_email).once
    end
  end

  describe '#submitted' do
    context 'when a candidate has a submitted application' do
      before do
        create(:submitted_application_choice, :with_completed_application_form, status: 'rejected', candidate: candidate)
      end

      it 'returns true' do
        submitted = described_class.new(candidate).submitted
        expect(submitted).to eq(true)
      end
    end

    context 'when a candidate does not have any submitted applications' do
      before do
        create(:application_choice, :application_not_sent, candidate: candidate)
      end

      it 'returns false' do
        submitted = described_class.new(candidate).submitted
        expect(submitted).to eq(false)
      end
    end
  end
end
