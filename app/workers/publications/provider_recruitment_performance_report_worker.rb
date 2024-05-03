module Publications
  class ProviderRecruitmentPerformanceReportWorker
    include Sidekiq::Worker

    sidekiq_options retry: 3, queue: :default

    def perform(cycle_week:, provider_id:)
      ProviderRecruitmentPerformanceReportGenerator.new(
        provider_id:,
        cycle_week:,
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
