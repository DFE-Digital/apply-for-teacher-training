require 'rails_helper'

RSpec.describe DataMigrations::DeletePreviousCycleNonFinalWeekReports do
  let(:previous_year) { RecruitmentCycleTimetable.previous_year }
  let(:current_year) { RecruitmentCycleTimetable.current_year }

  describe '#change' do
    context 'when the previous cycle has a national report' do
      let!(:reports_to_keep) do
        [
          create(:national_recruitment_performance_report, recruitment_cycle_year: previous_year, cycle_week: 52),
          create(:regional_recruitment_performance_report, recruitment_cycle_year: previous_year, cycle_week: 52),
          create(:regional_edi_report, recruitment_cycle_year: previous_year, cycle_week: 52),
          create(:provider_recruitment_performance_report, recruitment_cycle_year: previous_year, cycle_week: 52),
          create(:provider_edi_report, recruitment_cycle_year: previous_year, cycle_week: 52),
          create(:national_recruitment_performance_report, recruitment_cycle_year: current_year, cycle_week: 10),
          create(:regional_recruitment_performance_report, recruitment_cycle_year: current_year, cycle_week: 10),
          create(:regional_edi_report, recruitment_cycle_year: current_year, cycle_week: 10),
          create(:provider_recruitment_performance_report, recruitment_cycle_year: current_year, cycle_week: 10),
          create(:provider_edi_report, recruitment_cycle_year: current_year, cycle_week: 10),
        ]
      end

      let!(:reports_to_delete) do
        [
          create(:national_recruitment_performance_report, recruitment_cycle_year: previous_year, cycle_week: 51),
          create(:regional_recruitment_performance_report, recruitment_cycle_year: previous_year, cycle_week: 51),
          create(:regional_edi_report, recruitment_cycle_year: previous_year, cycle_week: 51),
          create(:provider_recruitment_performance_report, recruitment_cycle_year: previous_year, cycle_week: 51),
          create(:provider_edi_report, recruitment_cycle_year: previous_year, cycle_week: 51),
        ]
      end

      it 'deletes previous cycle reports that are not in the final national report week' do
        described_class.new.change

        reports_to_delete.each do |report|
          expect(report.class.exists?(report.id)).to be(false)
        end
      end

      it 'keeps the final week of the previous cycle and the current cycle reports' do
        described_class.new.change

        reports_to_keep.each do |report|
          expect(report.class.exists?(report.id)).to be(true)
        end
      end
    end

    context 'when the previous cycle has no national report' do
      it 'does not delete any reports' do
        create(:provider_recruitment_performance_report, recruitment_cycle_year: previous_year, cycle_week: 51)

        expect { described_class.new.change }.not_to change(Publications::ProviderRecruitmentPerformanceReport, :count)
      end
    end
  end
end
