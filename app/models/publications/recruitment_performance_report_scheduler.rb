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
        .perform_async(cycle_week:)
    end

    def schedule_provider_report
      provider_query.find_each do |provider|
        Publications::ProviderRecruitmentPerformanceReportWorker
          .perform_async(
            provider_id: provider.id,
            cycle_week:,
          )
      end
    end

    def provider_query
      Provider
        .joins(courses: { course_options: :application_choices })
        .where(courses: { recruitment_cycle_year: CycleTimetable.current_year })
        .where('application_choices.created_at < ?', Time.zone.today.beginning_of_week)
        .where.not(id: Publications::ProviderRecruitmentPerformanceReport.select('provider_id id').where(cycle_week:))
        .merge(ApplicationChoice.visible_to_provider)
    end

    def cycle_week
      CycleTimetable.current_cycle_week.pred
    end
  end
end
