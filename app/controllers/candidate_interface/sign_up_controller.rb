module CandidateInterface
  class SignUpController < CandidateInterfaceController
    def new
      @candidate = Candidate.new
    end

    def create
      @candidate = Candidate.new(candidate_params)

      if @candidate.save
        MagicLinkSignUp.call(candidate: @candidate)
        render :show
      else
        render :new
      end
    end

    def show; end

  private

    def candidate_params
      params.require(:candidate).permit(:email_address)
    end
  end
end
