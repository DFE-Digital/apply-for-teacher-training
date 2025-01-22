module CandidateInterface
  class SignInController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!
    before_action :redirect_to_application_if_signed_in, except: %i[confirm_authentication authenticate]
    before_action :redirect_to_sign_in_if_one_login_enabled

    def new
      candidate = Candidate.new
      render 'candidate_interface/sign_in/new', locals: { candidate: }
    end

    def create
      SignInCandidate.new(candidate_params[:email_address], self).call
    end

    # This is where users land after clicking the magic link in their email. Because
    # some email clients preload links in emails, this is an extra step where
    # they click a button to confirm the sign in.
    def confirm_authentication
      @authentication_token = AuthenticationToken.find_by_hashed_token(
        user_type: 'Candidate',
        raw_token: params[:token],
      )

      if @authentication_token&.still_valid?

        if @authentication_token.user.never_signed_in?
          render 'confirm_create_account'
        else
          render 'confirm_sign_in'
        end

      elsif @authentication_token
        # If the token is expired, redirect the user to a page
        # with their token as a param where they can request
        # a new sign in email.
        redirect_to candidate_interface_expired_sign_in_path(token: params[:token], path: params[:path])
      else
        redirect_to(action: :new)
      end
    end

    # After they click the confirm button, actually do the user sign in.
    def authenticate
      authentication_token = AuthenticationToken.find_by_hashed_token(
        user_type: 'Candidate',
        raw_token: params[:token],
      )

      redirect_to(action: :new) and return if authentication_token.nil?

      if authentication_token&.still_valid?
        candidate = authentication_token.user
        candidate.update!(candidate_api_updated_at: Time.zone.now) if candidate.last_signed_in_at.nil?
        sign_in(candidate, scope: :candidate)
        set_user_context(candidate.id)
        authentication_token.use!

        redirect_to candidate_interface_interstitial_path(path: params[:path])
      else
        redirect_to candidate_interface_expired_sign_in_path(token: params[:token], path: params[:path])
      end
    end

    def expired
      authentication_token = AuthenticationToken.find_by_hashed_token(
        user_type: 'Candidate',
        raw_token: params[:token],
      )

      if authentication_token.blank?
        redirect_to candidate_interface_sign_in_path
      end
    end

    def create_from_expired_token
      authentication_token = AuthenticationToken.find_by_hashed_token(
        user_type: 'Candidate',
        raw_token: params[:token],
      )

      candidate = authentication_token&.user

      if candidate
        set_user_context candidate.id
        redirect_to candidate_interface_sign_in_path(path: authentication_token&.path)
      else
        render 'errors/not_found', status: :forbidden
      end
    end

  private

    def candidate_params
      params.require(:candidate).permit(:email_address)
    end

    def redirect_to_sign_in_if_one_login_enabled
      if FeatureFlag.active?(:one_login_candidate_sign_in)
        redirect_to candidate_interface_create_account_or_sign_in_path
      end
    end
  end
end
