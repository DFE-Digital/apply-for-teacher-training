class PromptInactiveProviderUsersWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  queue_as :low_priority

  INACTIVE_MONTHS_AGO = RemoveInactiveProviderUsersWorker::INACTIVE_MONTHS_AGO
  PROMPT_WEEKS_BEFORE = 2

  def perform
    return if HostingEnvironment.qa? || HostingEnvironment.review? || HostingEnvironment.development?

    relation = ProviderUser.where(last_signed_in_at: almost_inactive_date.all_day)
      .or(
        ProviderUser.where(
          last_signed_in_at: nil,
          created_at: almost_inactive_date.all_day,
        ),
      )

    BatchDelivery.new(
      relation:,
      batch_size: 100,
      stagger_over: 10.minutes,
    ).each do |batch_time, provider_users|
      PromptInactiveProviderUsersBatchWorker.set(wait_until: batch_time).perform_later(
        provider_users.map(&:id),
        inactive_date,
      )
    end
  end

private

  def almost_inactive_date
    # 11 months and 2 weeks ago
    @prompt_date ||= INACTIVE_MONTHS_AGO.months.ago - PROMPT_WEEKS_BEFORE.weeks
  end

  def inactive_date
    # 2 weeks from now, making it inactive for 12 months
    PROMPT_WEEKS_BEFORE.weeks.from_now.to_date
  end
end
