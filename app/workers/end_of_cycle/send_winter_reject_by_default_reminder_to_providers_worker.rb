module EndOfCycle
  class SendWinterRejectByDefaultReminderToProvidersWorker < ApplicationJob
    BATCH_SIZE = 120

    def perform
      return unless send_email?

      BatchDelivery.new(relation:, batch_size: BATCH_SIZE).each do |batch_time, providers|
        SendWinterRejectByDefaultReminderToProvidersBatchWorker.perform_at(batch_time, providers.pluck(:id))
      end
    end

    def relation
      ids = ApplicationChoice.joins(:provider).course_starts_after_september(RecruitmentCycleTimetable.previous_year)
                             .where('application_choices.status': EndOfCycle::RejectByDefaultService::REJECTABLE_STATUSES)
                             .pluck('providers.id').uniq
      Provider.where(id: ids)
    end

  private

    def send_email?
      EndOfCycle::ProviderEmailTimetabler.new.send_winter_reject_by_default_reminder_to_providers?
    end
  end

  class SendWinterRejectByDefaultReminderToProvidersBatchWorker < ApplicationJob
    def perform(provider_ids)
      Provider.where(id: provider_ids).includes(:provider_users).find_each do |provider|
        SendWinterRejectByDefaultReminderToProvidersService.new(provider).call
      end
    end
  end
end
