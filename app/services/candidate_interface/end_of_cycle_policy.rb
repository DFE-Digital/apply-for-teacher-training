module CandidateInterface
  class EndOfCyclePolicy
    def self.can_add_course_choice?(application_form)
      return true if Time.zone.now.to_date >= CycleTimetableQuery.find_reopens && !application_form.must_be_carried_over?
      return true if Time.zone.now.to_date <= CycleTimetableQuery.apply_1_deadline && application_form.apply_1?
      return true if Time.zone.now.to_date <= CycleTimetableQuery.apply_2_deadline && application_form.apply_2?

      false
    end

    def self.can_submit?(application_form)
      RecruitmentCycle.current_year == application_form.recruitment_cycle_year
    end

    def self.before_find_reopens?
      return true if Time.zone.now.to_date <= CycleTimetableQuery.find_reopens.beginning_of_day

      false
    end

    def self.before_apply_reopens?
      return true if Time.zone.now.to_date <= CycleTimetableQuery.apply_reopens.beginning_of_day

      false
    end
  end
end
