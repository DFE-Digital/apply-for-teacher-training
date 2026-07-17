class PromptInactiveProviderUsersBatchWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  queue_as :low_priority

  def perform(provider_user_ids, inactive_date)
    ProviderUser.where(id: provider_user_ids).find_each do |provider_user|
      ProviderMailer
        .inactive_user_prompt(provider_user, inactive_date)
        .deliver_later
    end
  end
end
