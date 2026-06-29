module Publications
  class ProviderRecruitmentPerformanceReportWorker < ApplicationJob
    queue_as :default

    retry_on StandardError, attempts: 3

    def perform(provider_id, cycle_week, recruitment_cycle_year)
      ProviderRecruitmentPerformanceReportGenerator.new(
        provider_id:,
        cycle_week:,
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
