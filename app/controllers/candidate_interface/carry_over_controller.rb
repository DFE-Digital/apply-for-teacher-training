module CandidateInterface
  class CarryOverController < CandidateInterfaceController
    def start
      if EndOfCycleTimetable.between_cycles_apply_2?
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
  end
end
