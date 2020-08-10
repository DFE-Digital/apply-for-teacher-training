module CandidateInterface
  class CanAddCourseChoice
    def self.can_add_course_choice?(application_form:)
      return true if Time.zone.now > EndOfCycleTimetable.find_reopens

      case application_form.phase
      when 'apply_1'
        return true if Time.zone.now < EndOfCycleTimetable.apply_1_deadline
      else
        return true if Time.zone.now < EndOfCycleTimetable.apply_2_deadline
      end

      false
    end
  end
end
