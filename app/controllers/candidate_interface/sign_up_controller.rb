module CandidateInterface
  class SignUpController < CandidateInterfaceController
    def new
      @candidate = Candidate.new
    end

    def create
      @candidate = Candidate.find_or_initialize_by(candidate_params)

      if @candidate.persisted?
        MagicLinkSignIn.call(candidate: @candidate)
        render 'candidate_interface/shared/check_your_email'
      elsif @candidate.save
        MagicLinkSignUp.call(candidate: @candidate)
        render 'candidate_interface/shared/check_your_email'
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
