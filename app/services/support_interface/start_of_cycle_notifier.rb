module SupportInterface
  class StartOfCycleNotifier
    def call(service:, batch_size: 500, year: RecruitmentCycle.current_year)
      return unless CycleTimetable.service_opens_today?(service, year: year)

      StartOfCycleNotificationWorker.perform_async(service, batch_size)
    end
  end
end
