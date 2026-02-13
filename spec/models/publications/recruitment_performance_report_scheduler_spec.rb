require 'rails_helper'

RSpec.describe Publications::RecruitmentPerformanceReportScheduler do
  let(:provider_worker) { Publications::ProviderRecruitmentPerformanceReportWorker }
  let(:national_worker) { Publications::NationalRecruitmentPerformanceReportWorker }
  let(:regional_worker) { Publications::RegionalRecruitmentPerformanceReportWorker }
  let(:regional_edi_worker) { Publications::RegionalEdiReportWorker }
  let(:provider_edi_worker) { Publications::ProviderEdiReportWorker }
  let(:course_option) { create(:course_option) }
  let(:application_choice) { create(:application_choice, status: 'awaiting_provider_decision', course_option:, sent_to_provider_at: Time.zone.today - 1.week) }
  let(:provider) { course_option.course.provider }

  let(:cycle_week) { current_cycle_week.pred }
  let(:recruitment_cycle_year) { current_year }

  context 'provider report is generated for appropriate providers' do
    before do
      allow(HostingEnvironment).to receive(:production?).and_return true
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
      create(:provider_recruitment_performance_report, provider:, cycle_week:, recruitment_cycle_year: previous_year)

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
      allow(HostingEnvironment).to receive(:production?).and_return true
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
        recruitment_cycle_year: previous_year,
      )

      described_class.new.call

      expect(national_worker).to have_received(:perform_async).with(cycle_week)
    end

    it 'does not create a National report worker when a report already exists' do
      Publications::NationalRecruitmentPerformanceReport.create!(
        statistics: {},
        publication_date: Time.zone.today,
        cycle_week:,
        recruitment_cycle_year: current_year,
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

  context 'regional report is generated' do
    before do
      allow(HostingEnvironment).to receive(:production?).and_return true
      allow(regional_worker).to receive(:perform_async)
    end

    it 'creates a Regional report' do
      described_class.new.call

      Publications::RegionalRecruitmentPerformanceReport.regions.each_value do |region|
        expect(regional_worker).to have_received(:perform_async).with(cycle_week, region)
      end
    end

    it 'does creates a Regional report worker when a report already exists for the same cycle_week, but different year' do
      Publications::RegionalRecruitmentPerformanceReport.create!(
        statistics: {},
        publication_date: Time.zone.today,
        cycle_week:,
        recruitment_cycle_year: previous_year,
        region: 'West Midlands (England)',
      )

      described_class.new.call

      expect(regional_worker).to have_received(:perform_async).with(cycle_week, 'West Midlands (England)')
    end

    it 'does not create a Regional report worker when a report already exists' do
      Publications::RegionalRecruitmentPerformanceReport.create!(
        statistics: {},
        publication_date: Time.zone.today,
        cycle_week:,
        recruitment_cycle_year: current_year,
        region: :west_midlands,
      )

      described_class.new.call

      expect(regional_worker).not_to have_received(:perform_async).with(cycle_week, 'West Midlands (England)')
    end

    context 'explicit cycle_week is passed' do
      let(:cycle_week) { 2 }

      it 'creates a regional report for the cycle_week value' do
        described_class.new(cycle_week:).call

        Publications::RegionalRecruitmentPerformanceReport.regions.each_value do |region|
          expect(regional_worker).to have_received(:perform_async).with(cycle_week, region)
        end
      end
    end
  end

  context 'regional edi report is generated' do
    before do
      allow(HostingEnvironment).to receive(:production?).and_return true
      allow(regional_edi_worker).to receive(:perform_async)
    end

    it 'creates a Regional edi report' do
      described_class.new.call

      Publications::RegionalEdiReport.regions.each_value do |region|
        Publications::RegionalEdiReport.categories.each_value do |category|
          expect(regional_edi_worker).to have_received(:perform_async).with(cycle_week, region, category)
        end
      end
    end

    context 'explicit cycle_week is passed' do
      let(:cycle_week) { 16 }

      it 'does creates a Regional edi report worker when a report already exists for the same cycle_week, but different year' do
        create(:regional_edi_report, recruitment_cycle_year: previous_year)
        described_class.new(cycle_week:).call

        expect(regional_edi_worker).to have_received(:perform_async).with(cycle_week, 'London', 'Sex')
      end

      it 'does not create a Regional edi report worker when a report already exists' do
        create(:regional_edi_report, recruitment_cycle_year: current_year)
        described_class.new(cycle_week:).call

        expect(regional_edi_worker).not_to have_received(:perform_async).with(cycle_week, 'London', 'Sex')
      end

      it 'creates a regional edi report for the cycle_week value' do
        described_class.new(cycle_week:).call

        Publications::RegionalEdiReport.regions.each_value do |region|
          Publications::RegionalEdiReport.categories.each_value do |category|
            expect(regional_edi_worker).to have_received(:perform_async).with(cycle_week, region, category)
          end
        end
      end
    end
  end

  context 'provider edi report is generated' do
    before do
      allow(HostingEnvironment).to receive(:production?).and_return true
      allow(provider_edi_worker).to receive(:perform_async)
      application_choice
    end

    it 'creates a Provider edi report' do
      described_class.new.call

      Publications::ProviderEdiReport.categories.each_value do |category|
        expect(provider_edi_worker).to have_received(:perform_async).with(provider.id, cycle_week, category)
      end
    end

    context 'explicit cycle_week is passed' do
      let(:cycle_week) { 16 }

      it 'does creates a Provider edi report worker when a report already exists for the same cycle_week, but different year' do
        create(:provider_recruitment_performance_report, provider:, cycle_week:, recruitment_cycle_year: previous_year)
        described_class.new(cycle_week:).call

        expect(provider_edi_worker).to have_received(:perform_async).with(provider.id, cycle_week, 'Sex')
      end

      it 'does not create a Provider edi report worker when a report already exists' do
        create(:provider_recruitment_performance_report, provider:, cycle_week:, recruitment_cycle_year: current_year)
        described_class.new(cycle_week:).call

        expect(provider_edi_worker).not_to have_received(:perform_async).with(provider.id, cycle_week, 'Sex')
      end

      it 'creates a Provider edi report for the cycle_week value' do
        described_class.new(cycle_week:).call

        Publications::ProviderEdiReport.categories.each_value do |category|
          expect(provider_edi_worker).to have_received(:perform_async).with(provider.id, cycle_week, category)
        end
      end
    end
  end

  context 'non-production environment' do
    let(:provider_worker) { Publications::ProviderRecruitmentPerformanceReportWorker }
    let(:national_worker) { Publications::NationalRecruitmentPerformanceReportWorker }
    let(:regional_worker) { Publications::RegionalRecruitmentPerformanceReportWorker }
    let(:regional_edi_worker) { Publications::RegionalEdiReportWorker }
    let(:provider_edi_worker) { Publications::ProviderEdiReportWorker }
    let(:course_option) { create(:course_option) }
    let(:application_choice) { create(:application_choice, status: 'awaiting_provider_decision', course_option:, sent_to_provider_at: Time.zone.today - 1.week) }
    let(:provider) { course_option.course.provider }

    let(:cycle_week) { 16 }
    let(:recruitment_cycle_year) { RecruitmentCycleTimetable.current_year }

    before do
      allow(HostingEnvironment).to receive(:production?).and_return false
      allow(national_worker).to receive(:perform_async)
      allow(regional_worker).to receive(:perform_async)
      allow(regional_edi_worker).to receive(:perform_async)
      allow(provider_edi_worker).to receive(:perform_async)
      allow(provider_worker).to receive(:perform_async)
    end

    it 'does not create any reports' do
      described_class.new(cycle_week:).call
      expect(national_worker).not_to have_received(:perform_async).with(cycle_week)
      Publications::RegionalRecruitmentPerformanceReport.regions.each_value do |region|
        expect(regional_worker).not_to have_received(:perform_async).with(cycle_week, region)
      end

      Publications::RegionalEdiReport.regions.each_value do |region|
        Publications::RegionalEdiReport.categories.each_value do |category|
          expect(regional_edi_worker).not_to have_received(:perform_async).with(cycle_week, region, category)
        end
      end

      Publications::ProviderEdiReport.categories.each_value do |category|
        expect(provider_edi_worker).not_to have_received(:perform_async).with(provider.id, cycle_week, category)
      end

      expect(provider_worker).not_to have_received(:perform_async).with(provider.id, cycle_week)
    end
  end
end
