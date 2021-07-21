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
      redirect_to candidate_interface_application_form_path
    end

  private

    def redirect_if_already_carried_over
      return if current_application.carry_over?

      redirect_to candidate_interface_application_form_path
    end
  end
end
