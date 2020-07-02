require 'rails_helper'

RSpec.describe ValidationErrorSummaryQuery do
  describe '#call' do
    it 'returns an empty result' do
      expect(described_class.new.call).to eq({
        last_week: { distinct_users: 0, incidents: 0 },
        last_month: { distinct_users: 0, incidents: 0 },
        all_time: { distinct_users: 0, incidents: 0 },
      })
    end

    it 'returns data for each time period' do
      create :validation_error, created_at: 2.days.ago
      create :validation_error, created_at: 10.days.ago
      old_error = create :validation_error, created_at: 60.days.ago
      create :validation_error, created_at: 60.days.ago, user: old_error.user

      expect(described_class.new.call).to eq({
        last_week: { distinct_users: 1, incidents: 1 },
        last_month: { distinct_users: 2, incidents: 2 },
        all_time: { distinct_users: 3, incidents: 4 },
      })
    end
  end
end
