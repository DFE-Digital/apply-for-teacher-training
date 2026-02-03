module Publications
  class ProviderRecruitmentPerformanceReminderWorker
    include Sidekiq::Worker

    sidekiq_options retry: 3, queue: :default

    def perform
      cycle_week = RecruitmentCycleTimetable.current_cycle_week.pred
      recruitment_cycle_year = RecruitmentCycleTimetable.current_year

      return if Publications::NationalRecruitmentPerformanceReport.find_by(
        cycle_week:, recruitment_cycle_year:,
      ).blank?

      provider_ids = Publications::ProviderRecruitmentPerformanceReport.where(
        cycle_week:, recruitment_cycle_year:,
      ).pluck(:provider_id)

      relation = ProviderUser.joins(:provider_permissions).where('provider_permissions.provider_id' => provider_ids)

      ArrayBatchDelivery.new(relation:, stagger_over:).each do |scheduled_time, batch|
        batch.each do |provider_user|
          ProviderMailer
          .recruitment_performance_report_reminder(provider_user)
          .deliver_later(wait_until: scheduled_time)
        end
      end
    end

  private

    def stagger_over
      60.minutes
    end
  end
end
