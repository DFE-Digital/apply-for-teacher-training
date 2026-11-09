require 'rails_helper'

RSpec.describe Publications::DeleteOldReportsWorker do
  let(:current_year) { RecruitmentCycleTimetable.current_year }
  let(:previous_year) { RecruitmentCycleTimetable.previous_year }
  let(:report_types) do
    %i[
      national_recruitment_performance_report
      regional_recruitment_performance_report
      regional_edi_report
      provider_recruitment_performance_report
      provider_edi_report
    ]
  end

  before do
    allow(RecruitmentCycleTimetable).to receive(:current_cycle_week).and_return(40)
  end

  describe '#perform' do
    context 'with recruitment performance reports in the current cycle' do
      it 'deletes reports older than 26 weeks and keeps the rest' do
        old_reports = report_types.map { |type| create(type, recruitment_cycle_year: current_year, cycle_week: 13) }
        recent_reports = report_types.map { |type| create(type, recruitment_cycle_year: current_year, cycle_week: 14) }

        described_class.new.perform

        old_reports.each { |report| expect(report.class.exists?(report.id)).to be(false) }
        recent_reports.each { |report| expect(report.class.exists?(report.id)).to be(true) }
      end
    end

    context 'with recruitment performance reports in the previous cycle' do
      it 'keeps only the final week of the national report' do
        final_week_reports = report_types.map { |type| create(type, recruitment_cycle_year: previous_year, cycle_week: 51) }
        other_week_reports = report_types.map { |type| create(type, recruitment_cycle_year: previous_year, cycle_week: 30) }

        described_class.new.perform

        final_week_reports.each { |report| expect(report.class.exists?(report.id)).to be(true) }
        other_week_reports.each { |report| expect(report.class.exists?(report.id)).to be(false) }
      end

      it 'does not delete previous cycle reports when there is no national report' do
        report = create(:provider_recruitment_performance_report, recruitment_cycle_year: previous_year, cycle_week: 30)

        described_class.new.perform

        expect(Publications::ProviderRecruitmentPerformanceReport.exists?(report.id)).to be(true)
      end
    end

    context 'with recruitment performance reports older than the previous cycle' do
      it 'deletes all of them' do
        reports = report_types.map { |type| create(type, recruitment_cycle_year: previous_year - 1, cycle_week: 52) }

        described_class.new.perform

        reports.each { |report| expect(report.class.exists?(report.id)).to be(false) }
      end
    end

    context 'with withdrawal reasons reports' do
      it 'deletes previous cycle reports and current cycle reports older than 6 months' do
        previous_cycle_report = create(:withdrawal_reasons_report, recruitment_cycle_year: previous_year)
        old_report = create(:withdrawal_reasons_report, recruitment_cycle_year: current_year, created_at: 7.months.ago)
        recent_report = create(:withdrawal_reasons_report, recruitment_cycle_year: current_year, created_at: 1.day.ago)

        described_class.new.perform

        expect(Publications::WithdrawalReasonsReport.exists?(previous_cycle_report.id)).to be(false)
        expect(Publications::WithdrawalReasonsReport.exists?(old_report.id)).to be(false)
        expect(Publications::WithdrawalReasonsReport.exists?(recent_report.id)).to be(true)
      end
    end
  end
end
