module Publications
  class ProviderRecruitmentPerformanceReminderWorker
    include Sidekiq::Worker

    sidekiq_options retry: 3, queue: :default

    def perform
      return if Publications::NationalRecruitmentPerformanceReport.find_by(generation_date: Time.zone.now).blank?

      provider_ids = Publications::ProviderRecruitmentPerformanceReport.where(
        generation_date: Time.zone.now,
      ).pluck(:provider_id)
      ProviderUser.joins(:provider_permissions).where('provider_permissions.provider_id' => provider_ids).find_in_batches do |provider_user_batch|
        provider_user_batch.each do |provider_user|
          ProviderMailer.recruitment_performance_report_reminder(provider_user).deliver_later
        end
      end
    end
  end
end
