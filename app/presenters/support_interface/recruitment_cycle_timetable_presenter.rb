module SupportInterface
  class RecruitmentCycleTimetablePresenter
    delegate_missing_to :timetable
    attr_reader :timetable, :next_timetable

    def initialize(timetable)
      @timetable = timetable
      @next_timetable = timetable.relative_next_timetable
    end

    def cycle_state
      if next_timetable.present? && next_timetable.after_find_opens?
        :find_has_reopened
      elsif timetable.after_find_closes?
        :after_find_has_closed
      elsif timetable.after_decline_by_default?
        :after_decline_by_default
      elsif timetable.after_reject_by_default?
        :after_reject_by_default
      elsif timetable.after_apply_deadline?
        :after_apply_deadline
      elsif timetable.approaching_apply_deadline?
        :apply_deadline_approaching
      elsif timetable.after_apply_opens?
        :apply_has_opened
      elsif timetable.after_find_opens?
        :find_has_opened
      end
    end
  end
end
