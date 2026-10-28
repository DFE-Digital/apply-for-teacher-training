module Publications
  class WithdrawalReasonsReportWorker < ApplicationJob
    queue_as :default

    retry_on StandardError, attempts: 3

    def perform
      providers = Provider
        .distinct
        .joins(courses: { course_options: :application_choices })
        .where(courses: { recruitment_cycle_year: RecruitmentCycleTimetable.current_year })
        .merge(ApplicationChoice.visible_to_provider)

      providers.find_each.each do |provider|
        ProviderWithdrawalReasonsReportWorker.perform_later(provider.id)
      end
    end
  end

  class ProviderWithdrawalReasonsReportWorker < ApplicationJob
    queue_as :default

    retry_on StandardError, attempts: 3

    def perform(provider_id)
      Publications::WithdrawalReasonsReportGenerator.new(
        provider_id:,
        recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
      ).call
    end
  end
end
