module ProviderInterface
  class MissingPermission < StandardError
    attr_reader :permission, :provider, :provider_user

    def initialize(hash)
      @permission = hash[:permission]
      @provider = hash[:provider]
      @provider_user = hash[:provider_user]
    end
  end

  class ProviderInterfaceController < ActionController::Base
    include LogQueryParams

    before_action :authenticate_provider_user!
    before_action :add_identity_to_log
    before_action :check_data_sharing_agreements
    before_action :check_provider_relationship_permissions

    layout 'application'

    rescue_from MissingProvider, with: lambda { |e|
      Raven.capture_exception(e)

      render template: 'provider_interface/account_creation_in_progress', status: :forbidden
    }

    rescue_from ProviderInterface::MissingPermission, with: :permission_error

    helper_method :current_provider_user, :dfe_sign_in_user

    def current_provider_user
      !@current_provider_user.nil? ? @current_provider_user : @current_provider_user = (ProviderUser.load_from_session(session) || false)
    end

    alias_method :audit_user, :current_provider_user

  protected

    def permission_error(e)
      Raven.capture_exception(e)
      @error = e
      render template: 'provider_interface/permission_error', status: :forbidden
    end

    def dfe_sign_in_user
      DfESignInUser.load_from_session(session)
    end

    def authenticate_provider_user!
      return if current_provider_user

      session['post_dfe_sign_in_path'] = request.fullpath
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

    def check_provider_relationship_permissions
      return unless FeatureFlag.active?('enforce_provider_to_provider_permissions')
      return if request.path == provider_interface_provider_relationship_permissions_setup_path
      return unless current_provider_user

      if provider_permissions_need_setup?
        redirect_to provider_interface_provider_relationship_permissions_setup_path
      end
    end

    def provider_permissions_need_setup?
      permissions = TrainingProviderPermissions.find_by(
        setup_at: nil,
        training_provider: current_provider_user.providers,
      )

      return false if permissions.blank?

      ProviderAuthorisation.new(actor: current_provider_user).can_manage_organisation?(
        provider: permissions.training_provider,
      )
    end

    def render_404
      render 'errors/not_found', status: :not_found
    end

    def render_403
      render 'errors/forbidden', status: :forbidden
    end
  end
end
