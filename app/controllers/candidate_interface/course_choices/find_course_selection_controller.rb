module CandidateInterface
  module CourseChoices
    class FindCourseSelectionController < CandidateInterface::CourseChoices::BaseController
      include CandidateInterface::CourseChoices::Concerns::DuplicateCourseRedirect
      include CandidateInterface::CourseChoices::Concerns::FullCourseRedirect

      before_action :clear_wizard, only: [:new]

      def new
        super
      end

      def step_params
        if action_name == 'new'

          ActionController::Parameters.new(
            {
              current_step => {
                course_id: params[:course_id],
              },
            },
          )
        else
          super
        end
      end

    private

      def current_step
        :find_course_selection
      end

      def wizard_controller?
        true
      end
    end
  end
end
