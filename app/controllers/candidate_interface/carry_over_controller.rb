module CandidateInterface
  class CarryOverController < CandidateInterfaceController
    before_action :redirect_if_already_carried_over

    def start
      @application_form = current_application
      render 'candidate_interface/carry_over/not_submitted/start'
    end

    def create
      CarryOverApplication.new(current_application).call
      flash[:success] = 'Your application is ready for editing'
      redirect_to candidate_interface_before_you_start_path
    end

  private

    # How will we know if a form has been carried over?
    def redirect_if_already_carried_over
      return if must_be_carried_over?

      redirect_to candidate_interface_application_form_path
    end

    def must_be_carried_over?
      current_application.not_submitted_and_deadline_has_passed? || current_application.unsuccessful_and_apply_2_deadline_has_passed?
    end
  end
end
