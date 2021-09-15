module SupportInterface
  class StartOfCycleNotifier
    def call(service:, batch_size: 500, year: 2022)
      return unless service_opens_today?(service, year)

      StartOfCycleNotificationWorker.perform_async(service, batch_size)
    end

  private

    def service_opens_today?(service, year)
      current_cycles = CycleTimetable::CYCLE_DATES[year]
      service_opening_date = current_cycles[:"#{service}_opens"]

      Time.zone.now.between?(service_opening_date, service_opening_date.change(hour: 16, min: 1))
    end
  end
end
