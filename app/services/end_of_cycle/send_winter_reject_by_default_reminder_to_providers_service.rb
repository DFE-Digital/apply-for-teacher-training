module EndOfCycle
  class SendWinterRejectByDefaultReminderToProvidersService < SendRejectByDefaultReminderToProvidersService
    def chaser_type
      :respond_to_applications_before_winter_reject_by_default_date
    end
  end
end
