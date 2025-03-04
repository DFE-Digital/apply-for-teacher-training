require 'rails_helper'

RSpec.describe Publications::RecruitmentPerformanceReportScheduler do
  let(:provider_worker) { Publications::ProviderRecruitmentPerformanceReportWorker }
  let(:national_worker) { Publications::NationalRecruitmentPerformanceReportWorker }
  let(:course_option) { create(:course_option) }
  let(:application_choice) { create(:application_choice, status: 'awaiting_provider_decision', course_option:, sent_to_provider_at: Time.zone.today - 1.week) }
  let(:provider) { course_option.course.provider }

  let(:cycle_week) { RecruitmentCycleTimetable.current_cycle_week.pred }
  let(:recruitment_cycle_year) { RecruitmentCycleTimetable.current_year }

  context 'provider report is generated for appropriate providers' do
    before do
      allow(provider_worker).to receive(:perform_async)
      application_choice
    end

    it 'creates a report for a provider who has applications' do
      described_class.new.call

      expect(provider_worker).to have_received(:perform_async).with(provider.id, cycle_week)
    end

    it 'does not create a report if one has already been generated for that cycle week and year' do
      create(:provider_recruitment_performance_report, provider:, cycle_week:, recruitment_cycle_year:)

      described_class.new.call

      expect(provider_worker).not_to have_received(:perform_async).with(provider.id, cycle_week)
    end

    it 'creates a report if one has been generated for that cycle week in the previous year' do
      create(:provider_recruitment_performance_report, provider:, cycle_week:, recruitment_cycle_year: RecruitmentCycleTimetable.previous_year)

      described_class.new.call

      expect(provider_worker).to have_received(:perform_async).with(provider.id, cycle_week)
    end

    context 'explicit cycle_week is passed' do
      before do
        allow(ProvidersForRecruitmentPerformanceReportQuery)
          .to receive(:call)
                .with(cycle_week:, recruitment_cycle_year:)
                .and_return(Provider)
      end

      let(:cycle_week) { 2 }

      it 'creates a report for a provider who received an application before cycle_week' do
        described_class.new(cycle_week:).call

        expect(provider_worker).to have_received(:perform_async).with(provider.id, cycle_week)
      end
    end
  end

  context 'national report is generated' do
    before do
      allow(national_worker).to receive(:perform_async)
    end

    it 'creates a National report' do
      described_class.new.call

      expect(national_worker).to have_received(:perform_async).with(cycle_week)
    end

    it 'does creates a National report worker when a report already exists for the same cycle_week, but different year' do
      Publications::NationalRecruitmentPerformanceReport.create!(
        statistics: {},
        publication_date: Time.zone.today,
        cycle_week:,
        recruitment_cycle_year: RecruitmentCycleTimetable.previous_year,
      )

      described_class.new.call

      expect(national_worker).to have_received(:perform_async).with(cycle_week)
    end

    it 'does not create a National report worker when a report already exists' do
      Publications::NationalRecruitmentPerformanceReport.create!(
        statistics: {},
        publication_date: Time.zone.today,
        cycle_week:,
        recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
      )

      described_class.new.call

      expect(national_worker).not_to have_received(:perform_async).with(cycle_week)
    end

    context 'explicit cycle_week is passed' do
      let(:cycle_week) { 2 }

      it 'creates a national report for the cycle_week value' do
        described_class.new(cycle_week:).call

        expect(national_worker).to have_received(:perform_async).with(cycle_week)
      end
    end
  end
end
