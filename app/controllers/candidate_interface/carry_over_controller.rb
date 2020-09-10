module CandidateInterface
  class CarryOverController < CandidateInterfaceController
    def start
      render EndOfCycleTimetable.between_cycles_apply_2? ? :start_between_cycles : :start
    end

    def create
      CarryOverApplication.new(current_application).call
      flash[:success] = 'Your application is ready for editing'
      redirect_to candidate_interface_before_you_start_path
    end
  end
end
