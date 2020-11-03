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

    def confirm_authentication
      candidate = retrieve_candidate_by_token || retrieve_candidate_by_user_id

      redirect_to(action: :new) and return if candidate.nil?

      if FindCandidateByToken.token_not_expired?(candidate)
        render 'confirm_authentication'
      else
        redirect_to candidate_interface_expired_sign_in_path(u: params[:u], path: params[:path])
      end
    end

    def authenticate
      candidate = retrieve_candidate_by_token
      token_not_expired = FindCandidateByToken.token_not_expired?(candidate)

      if candidate.nil?
        candidate = retrieve_candidate_by_user_id
      end

      redirect_to(action: :new) and return if candidate.nil?

      if token_not_expired
        flash[:success] = t('apply_from_find.account_created_message') if candidate.last_signed_in_at.nil?
        sign_in(candidate, scope: :candidate)
        add_identity_to_log candidate.id
        candidate.update_sign_in_fields!

        redirect_to candidate_interface_interstitial_path(path: params[:path])
      else
        encrypted_candidate_id = Encryptor.encrypt(candidate.id)
        redirect_to candidate_interface_expired_sign_in_path(u: encrypted_candidate_id, path: params[:path])
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
        MagicLinkSignIn.call(candidate: candidate)
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

    def retrieve_candidate_by_token
      FindCandidateByToken.call(raw_token: params[:token])
    end

    def retrieve_candidate_by_user_id
      candidate_id = Encryptor.decrypt(params[:u])
      Candidate.find(candidate_id) if candidate_id
    end
  end
end
