module SupportInterface
  class ReportsController < SupportInterfaceController
    def index
      @previous_timetable = RecruitmentCycleTimetable.previous_timetable
    end
  end
end
