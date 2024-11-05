module ProviderInterface
  module Interviews
    class ChecksController < InterviewsController
      def new
        @wizard = InterviewWizard.new(interview_store, **interview_form_context_params, current_step: 'check', action:)
        @wizard.save_state!

        redirect_to new_provider_interface_application_choice_interview_path if @wizard.provider.blank?
      end

      def edit
        @interview = @application_choice.interviews.find(interview_id)

        @wizard = InterviewWizard.new(edit_interview_store(interview_id),
                                      interview_form_context_params.merge(current_step: 'check', action:))
        @wizard.save_state!
      end

      def create
        @wizard = InterviewWizard.new(interview_store, interview_params)
        @wizard.save_state!

        if @wizard.valid?
          redirect_to new_provider_interface_application_choice_interviews_check_path(@application_choice)
        else
          track_validation_error(@wizard)
          render 'provider_interface/interviews/new'
        end
      end

      def update
        @wizard = InterviewWizard.new(edit_interview_store(interview_id), interview_params)
        @wizard.save_state!
        @interview = @application_choice.interviews.find(interview_id)

        if @wizard.valid?
          redirect_to edit_provider_interface_application_choice_interview_check_path(@application_choice, @interview)
        else
          track_validation_error(@wizard)
          render 'provider_interface/interviews/edit'
        end
      end

    private

      def interview_id
        params.permit(:application_choice_interview_id)[:application_choice_interview_id]
      end
    end
  end
end
