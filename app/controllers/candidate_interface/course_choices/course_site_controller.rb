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
      end

    private

      def current_step
        :course_site
      end
    end
  end
end
