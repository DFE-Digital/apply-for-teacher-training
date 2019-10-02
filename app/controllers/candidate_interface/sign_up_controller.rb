module CandidateInterface
  class SignUpController < CandidateInterfaceController
    def new
      @candidate = Candidate.new
    end

    def create
      @candidate = Candidate.find_or_initialize_by(candidate_params)

      if @candidate.persisted?
        MagicLinkSignIn.call(candidate: @candidate)
        render 'candidate_interface/sign_in/show'
      elsif @candidate.save
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
