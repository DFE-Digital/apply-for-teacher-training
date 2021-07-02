module CandidateInterface
  class SubmittedApplicationFormController < CandidateInterfaceController
    before_action :redirect_to_application_form_unless_submitted, except: %i[start_carry_over carry_over]

    def review_submitted
      @application_form = current_application
    end

    def complete
      @candidate = current_candidate
      @application_form = current_application
    end

    def apply_again
      if ApplyAgain.new(current_application).call
        flash[:success] = 'We’ve copied your application. Please review all sections.'
        redirect_to candidate_interface_application_complete_path
      end
    end

    def start_carry_over
      render CycleTimetable.between_cycles_apply_2? ? :start_carry_over_between_cycles : :start_carry_over
    end

    def carry_over
      CarryOverApplication.new(current_application).call
      flash[:success] = 'Your application is ready for editing'
      redirect_to candidate_interface_before_you_start_path
    end
  end
end
