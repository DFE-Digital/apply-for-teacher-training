module CandidateInterface
  module CourseChoices
    class DoYouKnowWhichCourseController < CandidateInterface::CourseChoices::BaseController
    private

      def current_step
        :do_you_know_the_course
      end
    end
  end
end
