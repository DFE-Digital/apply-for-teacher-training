module Publications
  class RegionalRecruitmentPerformanceReportWorker
    include Sidekiq::Worker

    sidekiq_options retry: 3, queue: :default

    def perform(cycle_week, region)
      Publications::RegionalRecruitmentPerformanceReportGenerator.new(
        cycle_week:,
        region:,
        generation_date:,
        publication_date:,
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
