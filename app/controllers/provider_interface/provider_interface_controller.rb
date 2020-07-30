module ProviderInterface
  class AccessDenied < StandardError
    attr_reader :permission, :training_provider, :ratifying_provider, :provider_user

    def initialize(hash)
      @permission = hash[:permission]
      @training_provider = hash[:training_provider]
      @ratifying_provider = hash[:ratifying_provider]
      @provider_user = hash[:provider_user]
    end
  end

  class ProviderInterfaceController < ActionController::Base
    include LogQueryParams

    before_action :authenticate_provider_user!
    before_action :add_identity_to_log
    before_action :redirect_if_setup_required

    layout 'application'

    rescue_from MissingProvider, with: lambda { |e|
      Raven.capture_exception(e)

      render template: 'provider_interface/account_creation_in_progress', status: :forbidden
    }

    rescue_from ProviderInterface::AccessDenied, with: :permission_error

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

    def redirect_if_setup_required
      return unless current_provider_user

      # setup object is needed for hiding header links during provider setup
      @provider_setup = ProviderSetup.new(provider_user: current_provider_user)
      return if performing_provider_organisation_setup?

      if @provider_setup.next_agreement_pending
        redirect_to provider_interface_new_data_sharing_agreement_path
      elsif FeatureFlag.active?('enforce_provider_to_provider_permissions') &&
          @provider_setup.next_relationship_pending
        # redirect_to provider_interface_provider_relationship_permissions_setup_path
        # TODO: Implement this
      end
    end

    def performing_provider_organisation_setup?
      [
        ProviderInterface::ProviderAgreementsController,
      ].include?(request.controller_class)
    end

    def requires_make_decisions_permission
      auth = ProviderAuthorisation.new(actor: current_provider_user)

      if !auth.can_make_offer?(
        application_choice: @application_choice,
        course_option_id: @application_choice.offered_option.id,
      )
        raise ProviderInterface::AccessDenied.new({
          permission: 'make_decisions',
          training_provider: @application_choice.offered_course.provider,
          ratifying_provider: @application_choice.offered_course.accredited_provider,
          provider_user: current_provider_user,
        }), 'make_decisions required'
      end
    end

    def render_404
      render 'errors/not_found', status: :not_found
    end

    def render_403
      render 'errors/forbidden', status: :forbidden
    end
  end
end
