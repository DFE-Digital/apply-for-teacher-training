module Publications
  class RecruitmentPerformanceReportScheduler
    def initialize(cycle_week: RecruitmentCycleTimetable.current_cycle_week.pred, recruitment_cycle_year: RecruitmentCycleTimetable.current_year)
      @cycle_week = cycle_week
      @recruitment_cycle_year = recruitment_cycle_year
    end

    def call
      schedule_national_report
      schedule_provider_report
    end

  private

    attr_accessor :cycle_week, :recruitment_cycle_year

    def schedule_national_report
      return if Publications::NationalRecruitmentPerformanceReport.exists?(cycle_week:, recruitment_cycle_year:)

      Publications::NationalRecruitmentPerformanceReportWorker
        .perform_async(cycle_week)
    end

    def schedule_provider_report
      ProvidersForRecruitmentPerformanceReportQuery
        .call(cycle_week:, recruitment_cycle_year:)
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
