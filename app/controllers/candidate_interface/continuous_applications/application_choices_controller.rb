module CandidateInterface
  module ContinuousApplications
    class ApplicationChoicesController < ::CandidateInterface::ContinuousApplicationsController
      before_action :redirect_to_your_applications_if_submitted

      def submit
        @application_choice = application_choice
        @submit_application_form = CandidateInterface::ContinuousApplications::SubmitApplicationForm.new(
          application_choice: @application_choice,
          submit_answer:,
        )
        @application_can_submit = @submit_application_form.valid?(:submission)

        if @submit_application_form.valid?(:answer) && @submit_application_form.valid?(:submission)
          submit_application_choice
        else
          render 'candidate_interface/continuous_applications/course_choices/review/show'
        end
      end

      def confirm_destroy
        @application_choice = application_choice
      end

      def destroy
        CandidateInterface::DeleteApplicationChoice.new(application_choice:).call

        redirect_to candidate_interface_continuous_applications_choices_path
      end

    private

      def submit_application_choice
        if @submit_application_form.submit_now?
          CandidateInterface::ContinuousApplications::SubmitApplicationChoice.new(@application_choice).call
          flash[:success] = t('application_form.submit_application_success.title')
        end

        redirect_to candidate_interface_continuous_applications_choices_path
      end

      def submit_answer
        params.require(:candidate_interface_continuous_applications_submit_application_form).permit(:submit_answer)[:submit_answer]
      end

      def application_choice
        current_application
          .application_choices
          .find(params[:id])
      end
    end
  end
end
