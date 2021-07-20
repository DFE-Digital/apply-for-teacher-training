module CandidateInterface
  class CarryOverCallToActionComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def render?
      application_form.recruitment_cycle_year != RecruitmentCycle.current_year
    end

    def references_did_not_come_back_in_time?
      @application_form.references_did_not_come_back_in_time?
    end

    def between_cycles?
      CycleTimetable.between_cycles_apply_2?
    end

    def start_path
      candidate_interface_start_carry_over_path
    end

    def create_path
      candidate_interface_carry_over_path
    end
  end
end
