module CandidateInterface
  class WelcomeController < CandidateInterfaceController
    before_action :authenticate_candidate!

    def show; end
  end
end
