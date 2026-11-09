module Publications
  class DeleteOldReportsWorker < ApplicationJob
    queue_as :default

    retry_on StandardError, attempts: 3

    WEEKS_TO_KEEP = 26 # roughly 6 months

    REPORTS = [
      Publications::NationalRecruitmentPerformanceReport,
      Publications::RegionalRecruitmentPerformanceReport,
      Publications::RegionalEdiReport,
      Publications::ProviderRecruitmentPerformanceReport,
      Publications::ProviderEdiReport,
    ].freeze

    def perform
      # This keeps 6 months of recruitment reports in the current cycle
      # And just the last week of the previous cycle
      # It also keeps 6 months of WithdrawalReasonsReport

      current_year = RecruitmentCycleTimetable.current_year
      previous_year = RecruitmentCycleTimetable.previous_year
      oldest_week_to_keep = RecruitmentCycleTimetable.current_cycle_week - WEEKS_TO_KEEP
      previous_cycle_final_week = Publications::NationalRecruitmentPerformanceReport
        .last_in_year(previous_year)
        &.cycle_week

      REPORTS.each do |report|
        report.where(recruitment_cycle_year: current_year).where(
          'cycle_week < ? ', oldest_week_to_keep
        ).delete_all

        if previous_cycle_final_week.present?
          report.where(recruitment_cycle_year: previous_year).where.not(cycle_week: previous_cycle_final_week).delete_all
        end

        report.where('recruitment_cycle_year < ?', previous_year).delete_all
      end

      Publications::WithdrawalReasonsReport.where(
        recruitment_cycle_year: previous_year,
      ).delete_all

      Publications::WithdrawalReasonsReport.where(
        recruitment_cycle_year: current_year,
      ).where('created_at < ?', 6.months.ago).delete_all
    end
  end
end
