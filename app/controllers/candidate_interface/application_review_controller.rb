module CandidateInterface
  class ApplicationReviewController < CandidateInterfaceController
    before_action :authenticate_candidate!

    def show; end
  end
end
