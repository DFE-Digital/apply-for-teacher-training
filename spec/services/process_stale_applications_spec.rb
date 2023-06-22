require 'rails_helper'

RSpec.describe ProcessStaleApplications do
  let!(:application_choice) do
    create(
      :application_choice,
      :awaiting_provider_decision,
      reject_by_default_at: 1.business_days.ago,
    )
  end

  before do
    FeatureFlag.activate(:continuous_applications)
  end

  context 'when cycle is 2023', time: Time.zone.local(2023, 6, 20, 12, 10, 0) do
    it 'rejects an application that is ready for rejection but leaves other untouched' do
      other_application_choice = create(
        :application_choice,
        :awaiting_provider_decision,
        reject_by_default_at: 1.business_day.from_now,
      )

      described_class.new.call
      expect(other_application_choice.reload.status).to eq('awaiting_provider_decision')
      expect(application_choice.reload.status).to eq('rejected')
    end
  end

  context 'when 2024 recruitment cycle', time: Time.zone.local(2023, 11, 11, 11, 11, 11) do
    it 'rejects an application that is ready for rejection but leaves other untouched' do
      other_application_choice = create(
        :application_choice,
        :awaiting_provider_decision,
        reject_by_default_at: 1.business_day.from_now,
      )

      described_class.new.call
      expect(other_application_choice.reload.status).to eq('awaiting_provider_decision')
      expect(application_choice.reload.status).to eq('inactive')
    end
  end
end
