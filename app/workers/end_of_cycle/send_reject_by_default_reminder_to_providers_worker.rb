module EndOfCycle
  class SendRejectByDefaultReminderToProvidersWorker < ApplicationJob
    BATCH_SIZE = 120

    def perform
      return unless send_email?

      BatchDelivery.new(relation:, batch_size: BATCH_SIZE).each do |batch_time, providers|
        SendRejectByDefaultReminderToProvidersBatchWorker.set(wait_until: batch_time).perform_later(providers.pluck(:id))
      end
    end

    def relation
      if winter_reject_by_default_set?
        ids = ApplicationChoice.joins(:provider).course_start_in_september(RecruitmentCycleTimetable.current_year)
          .where('application_choices.status': EndOfCycle::RejectByDefaultService::REJECTABLE_STATUSES)
                         .pluck('providers.id').uniq
        Provider.where(id: ids)
      else
        Provider
          .joins(:application_choices)
          .where('application_choices.status': EndOfCycle::RejectByDefaultService::REJECTABLE_STATUSES)
          .distinct
      end
    end

  private

    def send_email?
      EndOfCycle::ProviderEmailTimetabler.new.send_reject_by_default_reminder_to_providers?
    end

    def winter_reject_by_default_set?
      EndOfCycle::ProviderEmailTimetabler.new.winter_reject_by_default_reminder_provider_date.present?
    end
  end

  class SendRejectByDefaultReminderToProvidersBatchWorker < ApplicationJob
    def perform(provider_ids)
      Provider.where(id: provider_ids).includes(:provider_users).find_each do |provider|
        SendRejectByDefaultReminderToProvidersService.new(provider).call
      end
    end
  end
end
