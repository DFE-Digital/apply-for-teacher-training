module Publications
  class RecruitmentPerformanceReportScheduler
    def call
      schedule_national_report
      schedule_provider_report
    end

  private

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
            provider_id: provider.id,
            cycle_week:,
          )
      end
    end

    def cycle_week
      CycleTimetable.current_cycle_week.pred
    end
  end
end
