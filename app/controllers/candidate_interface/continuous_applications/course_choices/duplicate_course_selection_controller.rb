module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class DuplicateCourseSelectionController < BaseController
        before_action :set_course

      private

        def step_params
          params[current_step] = {
            provider_id: params.delete(:provider_id),
            course_id: params.delete(:course_id),
          }
          params
        end

        def current_step
          :duplicate_course_selection
        end

        def set_course
          @course = Course.find(params[:course_id])
        end
      end
    end
  end
end
