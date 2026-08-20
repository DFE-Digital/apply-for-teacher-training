module CandidateInterface
  module CourseChoices
    class DoYouKnowWhichCourseController < CandidateInterface::CourseChoices::BaseController
      before_action :clear_wizard, only: [:new]

    private

      def current_step
        :do_you_know_the_course
      end

      def wizard_controller?
        true
      end
    end
  end
end
