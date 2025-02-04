module EndOfCycle
  class SendRejectByDefaultReminderToProvidersWorker
    include Sidekiq::Worker

    BATCH_SIZE = 120

    def perform
      return unless send_email?

      BatchDelivery.new(relation:, batch_size: BATCH_SIZE).each do |batch_time, providers|
        SendRejectByDefaultReminderToProvidersBatchWorker.perform_at(batch_time, providers.pluck(:id))
      end
    end

    def relation
      Provider
        .joins(:application_choices)
        .where('application_choices.status': EndOfCycle::RejectByDefaultService::REJECTABLE_STATUSES)
        .distinct
    end

  private

    def send_email?
      EndOfCycle::ProviderEmailTimetabler.new.send_reject_by_default_reminder_to_providers?
    end
  end

  class SendRejectByDefaultReminderToProvidersBatchWorker
    include Sidekiq::Worker

    def perform(provider_ids)
      Provider.where(id: provider_ids).includes(:provider_users).find_each do |provider|
        SendRejectByDefaultReminderToProvidersService.new(provider).call
      end
    end
  end
end
