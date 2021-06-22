module CandidateInterface
  class CarryOverController < CandidateInterfaceController
    before_action :redirect_if_already_carried_over

    def start
      if CycleTimetableQuery.between_cycles_apply_2?
        render current_application.submitted? ? :start_between_cycles : :start_between_cycles_unsubmitted
      else
        render :start
      end
    end

    def create
      CarryOverApplication.new(current_application).call
      flash[:success] = 'Your application is ready for editing'
      redirect_to candidate_interface_before_you_start_path
    end

  private

    def redirect_if_already_carried_over
      return if current_application.must_be_carried_over?

      redirect_to candidate_interface_application_form_path
    end
  end
end
