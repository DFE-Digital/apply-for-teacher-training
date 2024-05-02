require 'rails_helper'

RSpec.describe Publications::RecruitmentPerformanceReportScheduler do
  let(:provider_worker) { Publications::ProviderRecruitmentPerformanceReportWorker }
  let(:national_worker) { Publications::NationalRecruitmentPerformanceReportWorker }
  let(:provider_without_applications) { create(:course_option, :open).provider }
  let(:provider_with_application) { create(:application_choice, :awaiting_provider_decision).provider }
  let(:provider_with_unsubmitted_application) { create(:application_choice, :unsubmitted).provider }
  let(:previous_cycle_week) { CycleTimetable.current_cycle_week.pred }

  context 'provider report is generated for appropriate providers' do
    before do
      allow(provider_worker).to receive(:perform_async)
    end

    it 'creates a report for a provider who received an application last week' do
      TestSuiteTimeMachine.travel_permanently_to(Time.zone.local(2024, 4, 21, 18, 0))
      provider_with_application

      advance_time_to(1.day.from_now)

      described_class.new.call
      expect(provider_worker).to have_received(:perform_async).with(provider_id: provider_with_application.id, cycle_week: previous_cycle_week)
    end

    it 'does not create a report worker for a provider without any applications in the current cycle' do
      TestSuiteTimeMachine.travel_permanently_to(Time.zone.local(2024, 4, 21, 18, 0))
      # Create provider that has no applications but has an open course
      provider_without_applications

      advance_time_to(1.day.from_now)

      described_class.new.call
      expect(provider_worker).not_to have_received(:perform_async)
    end

    it 'does not create a report worker for a provider without a submitted application' do
      TestSuiteTimeMachine.travel_permanently_to(Time.zone.local(2024, 4, 21, 18, 0))
      # Create provider that has no applications but has an open course
      provider_with_unsubmitted_application

      advance_time_to(1.day.from_now)

      described_class.new.call
      expect(provider_worker).not_to have_received(:perform_async)
    end

    it 'does not create a report worker for a provider without an application in the current week' do
      TestSuiteTimeMachine.travel_permanently_to(Time.zone.local(2024, 4, 21, 18, 0))
      # Create provider that has an application this week
      provider_with_application

      described_class.new.call
      expect(provider_worker).not_to have_received(:perform_async).with(provider_id: provider_with_application.id)
    end
  end

  context 'national report is generated' do
    before do
      allow(national_worker).to receive(:perform_async)
    end

    it 'creates a National report' do
      described_class.new.call
      expect(national_worker).to have_received(:perform_async).with(cycle_week: previous_cycle_week)
    end
  end
end
