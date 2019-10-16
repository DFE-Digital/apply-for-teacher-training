module CandidateInterface
  class ApplicationSubmitController < CandidateInterfaceController
    before_action :authenticate_candidate!

    def show; end
  end
end
