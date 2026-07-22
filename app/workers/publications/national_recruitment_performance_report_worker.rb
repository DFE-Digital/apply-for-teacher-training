module Publications
  class NationalRecruitmentPerformanceReportWorker
    include Sidekiq::Worker

    sidekiq_options retry: 3, queue: :default

    def perform(cycle_week, recruitment_cycle_year)
      Publications::NationalRecruitmentPerformanceReportGenerator.new(
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
