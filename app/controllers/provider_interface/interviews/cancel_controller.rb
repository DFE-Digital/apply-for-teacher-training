module ProviderInterface
  module Interviews
    class CancelController < InterviewsController
      skip_before_action :redirect_to_index_if_store_cleared

      def new
        clear_wizard_if_new_entry(CancelInterviewWizard.new(cancel_interview_store(interview_id), {}))

        @interview = @application_choice.interviews.find(interview_id)
        @wizard = CancelInterviewWizard.new(cancel_interview_store(interview_id), { current_step: 'new', action: action })
        @wizard.referer ||= request.referer
        @wizard.save_state!
      end

      def create
        @interview = @application_choice.interviews.find(interview_id)

        @wizard = CancelInterviewWizard.new(cancel_interview_store(interview_id), cancellation_params)
        @wizard.save_state!

        if @wizard.valid?
          redirect_to provider_interface_application_choice_interview_cancel_path(@application_choice, @interview)
        else
          track_validation_error(@wizard)
          render 'provider_interface/interviews/cancel/new'
        end
      end

      def show
        @interview = @application_choice.interviews.find(interview_id)
        @wizard = CancelInterviewWizard.new(cancel_interview_store(interview_id), current_step: 'check', action: action)
        @wizard.save_state!
      end

    private

      def cancellation_params
        params.require(:provider_interface_cancel_interview_wizard).permit(:cancellation_reason)
      end

      def interview_id
        params.permit(:application_choice_interview_id)[:application_choice_interview_id]
      end

      def wizard_flow_controllers
        ['provider_interface/interviews/cancel'].freeze
      end
    end
  end
end
