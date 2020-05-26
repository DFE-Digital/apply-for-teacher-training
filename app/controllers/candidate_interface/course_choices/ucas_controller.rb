module CandidateInterface
  module CourseChoices
    class UCASController < BaseController
      def no_courses
        @provider = Provider.find_by!(id: params[:provider_id])
      end

      def with_course
        @provider = Provider.find_by!(id: params[:provider_id])
        @course = Course.find_by!(id: params[:course_id])
      end
    end
  end
end
