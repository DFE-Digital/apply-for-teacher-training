module CandidateInterface
  class ApplicationChoicesController < ::CandidateInterface::ContinuousApplicationsController
    before_action SubmissionPermissionFilter
    before_action :redirect_to_your_applications_if_submitted

    def submit
      @application_choice = application_choice
      @application_form = current_application
      @application_choice_submission = CandidateInterface::ContinuousApplications::ApplicationChoiceSubmission.new(
        application_choice: @application_choice,
      )

      if @application_choice_submission.valid?
        submit_application_choice
      else
        render 'candidate_interface/course_choices/review_and_submit/show'
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
      CandidateInterface::ContinuousApplications::SubmitApplicationChoice.new(@application_choice).call
      flash[:success] = t('application_form.submit_application_success.title')

      redirect_to candidate_interface_continuous_applications_choices_path
    end

    def application_choice
      current_application
        .application_choices
        .find(params[:id])
    end
  end
end
