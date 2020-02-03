require 'rails_helper'

RSpec.describe GetRefereesToChase do
  describe '#perform' do
    it 'returns referees that were sent their reference email more than 5 days ago and have not already been chased' do
      reference = create(:reference, feedback_status: 'feedback_requested', created_at: 6.days.ago)

      expect(described_class.call).to include reference
    end

    it 'only returns application choices which are awaiting references' do
      create(:reference, :complete, created_at: 6.days.ago)

      expect(described_class.call).to be_empty
    end

    it 'does not return referees which were sent their reference email less than 5 days ago' do
      create(:reference, feedback_status: 'feedback_requested', created_at: 4.days.ago)

      expect(described_class.call).to be_empty
    end


    it 'does not return referess who have already been sent a chase email' do
      reference = create(:reference, feedback_status: 'feedback_requested', created_at: 6.days.ago)

      SendChaseEmailToRefereeAndCandidate.call(application_form: reference.application_form, reference: reference)

      expect(described_class.call).to be_empty
    end
  end
end
