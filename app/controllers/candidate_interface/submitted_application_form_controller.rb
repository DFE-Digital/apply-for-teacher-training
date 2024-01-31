module CandidateInterface
  class SubmittedApplicationFormController < CandidateInterfaceController
    before_action AlreadyCarriedOverFilter, only: %i[complete]
    before_action :redirect_to_application_form_unless_submitted, except: %i[start_carry_over carry_over]

    def review_submitted
      @application_form = current_application
    end

    def complete
      @candidate = current_candidate
      @application_form = current_application
    end

    def start_carry_over
      render CycleTimetable.between_cycles_apply_2? ? :start_carry_over_between_cycles : :start_carry_over
    end

    def carry_over
      CarryOverApplication.new(current_application).call
      redirect_to candidate_interface_continuous_applications_details_path
    end

    def redirect_to_application_form_unless_submitted
      redirect_to candidate_interface_start_carry_over_path unless current_application.submitted?
    end
  end
end
