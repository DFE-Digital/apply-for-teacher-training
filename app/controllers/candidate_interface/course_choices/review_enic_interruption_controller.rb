module CandidateInterface
  module CourseChoices
    class ReviewEnicInterruptionController < CandidateInterface::CourseChoices::BaseController
      before_action :redirect_to_your_applications_if_submitted
      before_action :set_continue_without_editing_path
      before_action :viewed_enic_interruption_page, only: :show

      def show
        set_enic_reviewed_cookie
      end

    private

      def viewed_enic_interruption_page
        if cookies[:viewed_enic_interruption_page] == 'true'
          redirect_to @continue_without_editing_path
        end
      end

      def set_enic_reviewed_cookie
        cookies[:viewed_enic_interruption_page] = { value: 'true' }
      end

      def set_continue_without_editing_path
        @continue_without_editing_path = ReviewInterruptionPathDecider.decide_path(
          @application_choice,
          current_step: :enic,
        )
      end
    end
  end
end
