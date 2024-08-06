module CandidateInterface
  module CourseChoices
    class DoYouKnowWhichCourseController < CandidateInterface::CourseChoices::BaseController
    private

      def step_params
        params
      end

      def current_step
        :do_you_know_the_course
      end
    end
  end
end
