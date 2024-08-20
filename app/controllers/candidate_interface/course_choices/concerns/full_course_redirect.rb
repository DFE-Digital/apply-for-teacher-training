module CandidateInterface
  module CourseChoices
    module Concerns
      module FullCourseRedirect
        extend ActiveSupport::Concern

        included do
          before_action :redirect_full
        end

      private

        def redirect_full
          course = Course.find(params[:course_id])
          return if course.available?

          redirect_to candidate_interface_course_choices_full_course_selection_path(course.provider_id, course.id)
        end
      end
    end
  end
end
