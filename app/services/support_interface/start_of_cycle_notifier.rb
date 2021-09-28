module SupportInterface
  class StartOfCycleNotifier
    attr_reader :service, :year

    def initialize(service:, year: RecruitmentCycle.current_year)
      @service = service
      @year = year
    end

    def call
      return unless CycleTimetable.service_opens_today?(service, year: year)

      StartOfCycleNotificationWorker.perform_async(service, hours_remaining)
    end

  private

    def hours_remaining
      notify_until.hour - Time.zone.now.hour
    end

    def notify_until
      Time.zone.now.change(hour: 16)
    end
  end
end
