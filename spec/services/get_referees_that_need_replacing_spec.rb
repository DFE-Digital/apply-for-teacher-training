require 'rails_helper'

RSpec.describe GetRefereesThatNeedReplacing do
  describe '.call' do
    it 'returns referees that were sent their reference email more than 10 days ago and have not already been chased' do
      reference = create(:reference, feedback_status: 'feedback_requested', requested_at: 11.business_days.ago)

      expect(described_class.call).to include reference
    end

    it 'only returns application choices which are awaiting references' do
      create(:reference, :complete, requested_at: 11.business_days.ago)

      expect(described_class.call).to be_empty
    end

    it 'does not return referees which were sent their reference email less than 5 days ago' do
      create(:reference, feedback_status: 'feedback_requested', requested_at: 4.business_days.ago)

      expect(described_class.call).to be_empty
    end

    it 'does not return referees who have already been sent a chase email' do
      reference = create(:reference, feedback_status: 'feedback_requested', requested_at: 11.business_days.ago)

      SendNewRefereeRequestEmail.call(application_form: reference.application_form, reference: reference, reason: :not_responded)

      expect(described_class.call).to be_empty
    end
  end
end
