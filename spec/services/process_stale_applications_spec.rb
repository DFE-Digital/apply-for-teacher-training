require 'rails_helper'

RSpec.describe ProcessStaleApplications do
  context 'when cycle is 2023', continuous_applications: false do
    it 'rejects an application that is ready for rejection but leaves other untouched' do
      application_choice = create(
        :application_choice,
        :awaiting_provider_decision,
        reject_by_default_at: 1.business_days.ago,
        recruitment_cycle_year: 2023,
      )
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

  context 'when 2024 recruitment cycle', continuous_applications: true do
    it 'rejects an application that is ready for rejection but leaves other untouched' do
      application_choice = create(
        :application_choice,
        :awaiting_provider_decision,
        :continuous_applications,
        reject_by_default_at: 1.business_days.ago,
      )
      other_application_choice = create(
        :application_choice,
        :awaiting_provider_decision,
        :continuous_applications,
        reject_by_default_at: 1.business_day.from_now,
      )

      described_class.new.call
      expect(other_application_choice.reload.status).to eq('awaiting_provider_decision')
      expect(application_choice.reload.status).to eq('inactive')
    end
  end
end
