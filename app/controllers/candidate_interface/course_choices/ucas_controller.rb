module CandidateInterface
  module CourseChoices
    class UCASController < BaseController
      def no_courses
        @provider = Provider.find(params[:provider_id])
      end

      def with_course
        @provider = Provider.find(params[:provider_id])
        @course = Course.find(params[:course_id])
      end
    end
  end
end
