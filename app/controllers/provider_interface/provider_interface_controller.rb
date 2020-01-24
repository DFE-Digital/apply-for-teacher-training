module ProviderInterface
  class ProviderInterfaceController < ActionController::Base
    include LogQueryParams

    before_action :authenticate_provider_user!
    around_action :set_audit_username
    before_action :add_identity_to_log
    before_action :check_data_sharing_agreements

    layout 'application'

    rescue_from MissingProvider, with: ->(e) {
      Raven.capture_exception(e)

      render template: 'provider_interface/account_creation_in_progress', status: :forbidden
    }

    helper_method :current_provider_user, :dfe_sign_in_user

  private

    def set_audit_username
      Audited.audit_class.as_user(audit_username) do
        yield
      end
    end

    def audit_username
      current_provider_user ? "#{current_provider_user.email_address} (Provider)" : nil
    end

    def current_provider_user
      ProviderUser.load_from_session(session)
    end

    def dfe_sign_in_user
      DfESignInUser.load_from_session(session)
    end

    def authenticate_provider_user!
      return if current_provider_user

      session['post_dfe_sign_in_path'] = request.path

      if !current_provider_user && dfe_sign_in_user
        render(
          template: 'provider_interface/account_creation_in_progress',
          status: :forbidden,
        )
        return
      end

      session['post_dfe_sign_in_path'] = request.path
      redirect_to provider_interface_sign_in_path
    end

    def add_identity_to_log
      return unless current_provider_user

      RequestLocals.store[:identity] = { dfe_sign_in_uid: current_provider_user.dfe_sign_in_uid }
      Raven.user_context(dfe_sign_in_uid: current_provider_user.dfe_sign_in_uid)
    end

    def check_data_sharing_agreements
      if GetPendingDataSharingAgreementsForProviderUser.call(provider_user: current_provider_user).any?
        redirect_to provider_interface_new_data_sharing_agreement_path
      end
    end
  end
end
