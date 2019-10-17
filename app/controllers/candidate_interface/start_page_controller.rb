module CandidateInterface
  class StartPageController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!

    def show; end
  end
end
