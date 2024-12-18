module CandidateInterface
  module WithdrawalReasons
    class WithdrawalReasonsController < CandidateInterfaceController
      before_action :set_application_choice
      before_action :check_that_candidate_can_withdraw

    private

      def set_application_choice
        @application_choice = @current_application.application_choices.find(params[:id])
      end

      def check_that_candidate_can_withdraw
        unless ApplicationStateChange.new(@application_choice).can_withdraw?
          render_404
        end
      end
    end
  end
end
