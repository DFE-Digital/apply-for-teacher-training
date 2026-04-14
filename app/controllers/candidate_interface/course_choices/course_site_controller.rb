module CandidateInterface
  module CourseChoices
    class CourseSiteController < CandidateInterface::CourseChoices::BaseController
      include CandidateInterface::CourseChoices::Concerns::DuplicateCourseRedirect

      def edit
        @wizard = CandidateInterface::CourseChoices::CourseSelectionWizard.new(
          current_step:,
          step_params: update_params,
          current_application:,
          application_choice:,
          edit: true,
        )
        @wizard.current_step.set_course_option_id
        @back_link_path = if params[:return_to] == 'review'
                            candidate_interface_course_choices_course_review_path
                          else
                            @wizard.previous_step_path
                          end
      end

    private

      def current_step
        :course_site
      end
    end
  end
end
