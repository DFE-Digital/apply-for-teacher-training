module CandidateInterface
  module CourseChoices
    class ReviewEnicInterruptionController < CandidateInterface::CourseChoices::BaseController
      before_action :redirect_to_your_applications_if_submitted
      before_action :viewed_enic_interruption_page, only: :show

      def show
        set_enic_reviewed_cookie
      end

    private

      def viewed_enic_interruption_page
        if cookies[:viewed_enic_interruption_page] == 'true'
          redirect_to candidate_interface_course_choices_course_review_and_submit_path(@application_choice.id)
        end
      end

      def set_enic_reviewed_cookie
        cookies[:viewed_enic_interruption_page] = { value: 'true' }
      end
    end
  end
end
