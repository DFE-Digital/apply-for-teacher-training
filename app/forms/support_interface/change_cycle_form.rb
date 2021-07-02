module SupportInterface
  class ChangeCycleForm
    include ActiveModel::Model

    def cycle_schedule_name
      CycleTimetable.current_cycle_schedule
    end
  end
end
