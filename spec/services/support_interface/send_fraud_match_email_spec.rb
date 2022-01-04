require 'rails_helper'

RSpec.describe SupportInterface::SendFraudMatchEmail do
  describe '#call' do
    let(:fraud_match) { create(:fraud_match) }

    before do
      build(:application_form,
            candidate: fraud_match.candidates.first,
            first_name: 'Jeffrey',
            last_name: 'Thompson',
            date_of_birth: '1998-08-08',
            postcode: 'W6 9BH',
            submitted_at: Time.zone.now)

      build(:application_form,
            candidate: fraud_match.candidates.second,
            first_name: 'Joffrey',
            last_name: 'Thompson',
            date_of_birth: '1998-08-08',
            postcode: 'W6 9BH')

      mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(CandidateMailer).to receive(:fraud_match_email).and_return(mail)
    end

    it 'sends a chaser email to the candidate' do
      described_class.new(fraud_match).call

      expect(CandidateMailer).to have_received(:fraud_match_email).twice
    end
  end
end
