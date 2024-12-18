module CandidateInterface
  module WithdrawalReasons
    class WithdrawalsController < CandidateInterfaceController
      before_action :set_application_choice
      before_action :check_that_candidate_can_withdraw

      def create
        WithdrawApplication.new(application_choice: @application_choice).save!
        flash[:success] = I18n.t(
          'candidate_interface.withdrawal_reasons.success_message',
          provider_name: @application_choice.current_course_option.provider.name,
        )
        redirect_to candidate_interface_application_choices_path
      end

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
