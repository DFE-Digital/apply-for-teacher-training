require 'rails_helper'

RSpec.describe ValidationErrorSummaryQuery do
  describe '#call' do
    it 'returns an empty result' do
      expect(described_class.new.call).to eq([])
    end

    it 'returns data for each time period' do
      create :validation_error, created_at: 2.days.ago
      create :validation_error, created_at: 10.days.ago
      old_error = create :validation_error, created_at: 60.days.ago
      create :validation_error, created_at: 60.days.ago, user: old_error.user

      expect(described_class.new.call).to eq([
        {
          'attribute' => 'feedback',
          'form_object' => 'RefereeInterface::ReferenceFeedbackForm',
          'incidents_all_time' => 4,
          'incidents_last_month' => 2,
          'incidents_last_week' => 1,
          'unique_users_all_time' => 3,
          'unique_users_last_month' => 2,
          'unique_users_last_week' => 1,
        },
      ])
    end
  end
end
