module CandidateInterface
  class EndOfCyclePolicy
    def self.can_add_course_choice?(application_form)
      return true if Time.zone.now.to_date >= EndOfCycleTimetable.apply_reopens
      return true if Time.zone.now.to_date <= EndOfCycleTimetable.apply_1_deadline && application_form.apply_1?
      return true if Time.zone.now.to_date <= EndOfCycleTimetable.apply_2_deadline && application_form.apply_2?

      false
    end

    def self.cancel_application_because_option_unavailable?(application_choice)
      EndOfCycleTimetable.stop_applications_to_unavailable_course_options? &&
        (
          application_choice.course_option_full? ||
          application_choice.course_withdrawn?
        )
    end
  end
end
