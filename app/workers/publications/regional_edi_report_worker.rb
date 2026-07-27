module Publications
  class RegionalEdiReportWorker < ApplicationJob
    queue_as :default

    retry_on StandardError, attempts: 3

    def perform(cycle_week, region, recruitment_cycle_year)
      Publications::RegionalEdiReportGenerator.new(
        cycle_week:,
        region:,
        generation_date:,
        publication_date:,
        recruitment_cycle_year:,
      ).call
    end

  private

    def generation_date
      RecruitmentPerformanceReportTimetable.current_generation_date
    end

    def publication_date
      RecruitmentPerformanceReportTimetable.current_publication_date
    end
  end
end
