module Publications
  class RegionalEdiReportWorker
    include Sidekiq::Worker

    sidekiq_options retry: 3, queue: :default

    def perform(cycle_week, region, category)
      Publications::RegionalEdiReportGenerator.new(
        cycle_week:,
        region:,
        category:,
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
