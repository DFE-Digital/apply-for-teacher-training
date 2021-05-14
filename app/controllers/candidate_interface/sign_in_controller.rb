module CandidateInterface
  class SignInController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!
    before_action :redirect_to_application_if_signed_in, except: %i[confirm_authentication authenticate]

    def new
      candidate = Candidate.new
      render 'candidate_interface/sign_in/new', locals: { candidate: candidate }
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
        render 'confirm_authentication'

      elsif @authentication_token
        # If the token is expired, redirect the user to a page
        # with their token as a param where they can request
        # a new sign in email.
        redirect_to candidate_interface_expired_sign_in_path(token: params[:token], path: params[:path])
      elsif params[:u]
        redirect_to candidate_interface_expired_sign_in_path(u: params[:u], path: params[:path])
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
        first_sign_in = candidate.last_signed_in_at.nil?
        flash[:success] = t('apply_from_find.account_created_message') if first_sign_in
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

      if authentication_token.blank? && params[:u].blank?
        redirect_to candidate_interface_sign_in_path
      end
    end

    def create_from_expired_token
      encrypted_user_id = params[:u]
      authentication_token = AuthenticationToken.find_by_hashed_token(
        user_type: 'Candidate',
        raw_token: params[:token],
      )

      candidate =
        if encrypted_user_id.present?
          Candidate.find(Encryptor.decrypt(encrypted_user_id))
        elsif authentication_token
          authentication_token.user
        end

      if candidate
        CandidateInterface::RequestMagicLink.for_sign_in(candidate: candidate, path: authentication_token&.path)
        set_user_context candidate.id
        redirect_to candidate_interface_check_email_sign_in_path
      else
        render 'errors/not_found', status: :forbidden
      end
    end

  private

    def candidate_params
      params.require(:candidate).permit(:email_address)
    end
  end
end
