module CandidateInterface
  module CourseChoices
    class CourseSelectionController < BaseController
      def full
        @course = Course.find(params[:course_id])

        @return_to_path = ''
      end
    end
  end
end
