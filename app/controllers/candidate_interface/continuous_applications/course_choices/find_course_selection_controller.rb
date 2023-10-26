module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class FindCourseSelectionController < BaseController
        before_action :redirect_duplicate, only: %w[new] # rubocop:disable Rails/LexicallyScopedActionFilter

      private

        def current_step
          :find_course_selection
        end

        def redirect_duplicate
          course = Course.find(params[:course_id])
          return unless current_application.contains_course?(course)

          redirect_to candidate_interface_continuous_applications_duplicate_course_selection_path(course.provider_id, course.id)
        end
      end
    end
  end
end
