module CandidateInterface
  class EndOfCyclePolicy
    def self.can_add_course_choice?(application_form:)
      return true if Time.zone.now.to_date >= EndOfCycleTimetable.next_cycles_courses_open
      return true if Time.zone.now.to_date <= EndOfCycleTimetable.apply_1_deadline && application_form.apply_1?
      return true if Time.zone.now.to_date <= EndOfCycleTimetable.apply_2_deadline && application_form.apply_2?

      false
    end
  end
end
