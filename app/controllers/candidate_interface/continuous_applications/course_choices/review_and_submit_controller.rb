module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class ReviewAndSubmitController < BaseController
        before_action SubmissionPermissionFilter
        before_action :redirect_to_your_applications_if_submitted
        before_action :redirect_to_course_choice_review_unless_ready_to_submit

        def show
          @application_choice = current_application.application_choices.find(params[:application_choice_id])
          @application_form = current_application
        end

      private

        def redirect_to_course_choice_review_unless_ready_to_submit
          return if ready_to_submit?

          redirect_to(candidate_interface_continuous_applications_course_review_path(@application_choice.id))
        end

        def ready_to_submit?
          CandidateInterface::ContinuousApplications::ApplicationChoiceSubmission.new(application_choice: @application_choice).valid?
        end
      end
    end
  end
end
