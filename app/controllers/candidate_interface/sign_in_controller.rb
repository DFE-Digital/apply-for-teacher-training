module CandidateInterface
  class SignInController < CandidateInterfaceController
    def new
      @candidate = Candidate.new
    end

    def create
      render :show
    end
  end
end
