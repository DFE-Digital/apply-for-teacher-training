module CandidateInterface
  class CarryOverInsetTextComponent < ViewComponent::Base
    include ViewHelper

    def initialize(application_form:)
      @application_form = application_form
    end

    def render?
      @application_form.unsuccessful_and_apply_2_deadline_has_passed?
    end

    def application_form_academic_cycle
      academic_cycle_name(application_form_recruitment_cycle_year)
    end

    def next_academic_cycle
      academic_cycle_name(next_recruitment_cycle_year)
    end

    def carry_over_path
      candidate_interface_carry_over_path
    end

  private

    def academic_cycle_name(year)
      "#{year} to #{year + 1}"
    end

    def application_form_recruitment_cycle_year
      @application_form.recruitment_cycle_year
    end

    def next_recruitment_cycle_year
      application_form_recruitment_cycle_year + 1
    end
  end
end
