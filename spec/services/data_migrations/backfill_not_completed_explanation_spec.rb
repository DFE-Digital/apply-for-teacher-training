require 'rails_helper'

RSpec.describe DataMigrations::BackfillNotCompletedExplanation do
  it 'sets not_completed_yet to missing_explanation and set missing_explanation to nil' do
    Timecop.freeze do
      missing_gcse = create(
        :gcse_qualification,
        :missing,
        not_completed_explanation: nil,
        missing_explanation: 'Should get copied over.',
        updated_at: 1.day.ago,
      )

      non_missing_gcse = create(
        :gcse_qualification,
        missing_explanation: '',
      )

      described_class.new.change

      expect(missing_gcse.reload.not_completed_explanation).to eq 'Should get copied over.'
      expect(missing_gcse.currently_completing_qualification).to eq true
      expect(missing_gcse.missing_explanation).to eq nil
      expect(missing_gcse.updated_at).to be_within(1.second).of(1.day.ago)
      expect(non_missing_gcse.reload.missing_explanation).to eq ''
    end
  end
end
