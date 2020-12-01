module CandidateInterface
  class FindFeedbackController < CandidateInterfaceController
    def new
      @find_feedback_form = CandidateInterface::FindFeedbackForm.new(
        path: params[:path],
        original_controller: params[:original_controller],
      )
    end
  end
end
