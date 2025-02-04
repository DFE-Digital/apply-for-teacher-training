module Publications
  class RecruitmentPerformanceReportScheduler
    def initialize(cycle_week: RecruitmentCycleTimetable.current_cycle_week.pred)
      @cycle_week = cycle_week
    end

    def call
      schedule_national_report
      schedule_provider_report
    end

  private

    attr_accessor :cycle_week

    def schedule_national_report
      return if Publications::NationalRecruitmentPerformanceReport.exists?(cycle_week:)

      Publications::NationalRecruitmentPerformanceReportWorker
        .perform_async(cycle_week)
    end

    def schedule_provider_report
      ProvidersForRecruitmentPerformanceReportQuery
        .call(cycle_week:)
        .find_each do |provider|
        Publications::ProviderRecruitmentPerformanceReportWorker
          .perform_async(
            provider.id,
            cycle_week,
          )
      end
    end
  end
end
