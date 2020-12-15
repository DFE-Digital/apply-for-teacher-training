module CandidateInterface
  class SignInController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!
    before_action :redirect_to_application_if_signed_in, except: %i[authenticate]

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
      authentication_token = AuthenticationToken.find_by_hashed_token(
        authenticable_type: 'Candidate',
        raw_token: params[:token],
      )

      if authentication_token && authentication_token.still_valid?
        render 'confirm_authentication'
      elsif params[:u]
        # If the token is invalid or expired, redirect the user to a page
        # with their encryped user id as a param where they can request
        # a new sign in email.
        redirect_to candidate_interface_expired_sign_in_path(u: params[:u], path: params[:path])
      else
        redirect_to(action: :new)
      end
    end

    # After they click the confirm button, actually do the user sign in.
    def authenticate
      authentication_token = AuthenticationToken.find_by_hashed_token(
        authenticable_type: 'Candidate',
        raw_token: params[:token],
      )

      redirect_to(action: :new) and return if authentication_token.nil?

      if authentication_token && authentication_token.still_valid?
        candidate = authentication_token.authenticable
        flash[:success] = t('apply_from_find.account_created_message') if candidate.last_signed_in_at.nil?
        sign_in(candidate, scope: :candidate)
        add_identity_to_log(candidate.id)
        candidate.update!(last_signed_in_at: Time.zone.now)
        authentication_token.destroy!

        redirect_to candidate_interface_interstitial_path(path: params[:path])
      else
        redirect_to candidate_interface_expired_sign_in_path(u: params[:u], path: params[:path])
      end
    end

    def expired
      if params[:u].blank?
        redirect_to candidate_interface_sign_in_path
      end
    end

    def create_from_expired_token
      candidate_id = Encryptor.decrypt(params.fetch(:u))

      if candidate_id
        candidate = Candidate.find(candidate_id)
        CandidateInterface::RequestMagicLink.call(candidate: candidate)
        add_identity_to_log candidate.id
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
