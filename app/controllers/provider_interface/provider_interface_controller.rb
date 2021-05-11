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

  class ProviderInterfaceController < ApplicationController
    before_action :authenticate_provider_user!
    before_action :add_identity_to_log
    before_action :redirect_if_setup_required
    before_action :check_cookie_preferences

    layout 'application'

    rescue_from MissingProvider, with: lambda {
      render template: 'provider_interface/email_address_not_recognised', status: :forbidden
    }

    rescue_from ProviderInterface::AccessDenied, with: :permission_error

    helper_method :current_provider_user, :dfe_sign_in_user

    def current_provider_user
      @current_provider_user ||= ProviderUser.load_from_session(session)
    end

    alias_method :current_user, :current_provider_user

    def check_cookie_preferences
      if cookies['consented-to-manage-cookies'].eql?('yes')
        @provider_type = current_provider_user.primary_provider_type if current_provider_user
        @google_analytics_id = ENV.fetch('GOOGLE_ANALYTICS_MANAGE', '')
        @google_tag_manager_id = ENV.fetch('GOOGLE_TAG_MANAGER_MANAGE', '')
      end
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

      Raven.user_context(id: "provider_#{current_provider_user.id}")
      Raven.extra_context(useful_debugging_info)
    end

    def append_info_to_payload(payload)
      super

      payload.merge!(useful_debugging_info) if current_provider_user
      payload.merge!(application_support_url) if @application_choice
      payload.merge!(log_query_params)
    end

    # Set the `@application_choice` instance variable for use in views.
    def set_application_choice
      @application_choice = GetApplicationChoicesForProviders.call(
        providers: current_provider_user.providers,
      ).find(params[:application_choice_id])

      Raven.extra_context(application_support_url)
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    def redirect_if_setup_required
      return unless current_provider_user

      # setup object is needed for hiding header links during provider setup
      @provider_setup = ProviderSetup.new(provider_user: current_provider_user)
      return if performing_provider_organisation_setup?

      if @provider_setup.next_agreement_pending
        redirect_to provider_interface_new_data_sharing_agreement_path
      elsif @provider_setup.next_relationship_pending
        redirect_to provider_interface_provider_relationship_permissions_organisations_path
      end
    end

    def performing_provider_organisation_setup?
      [
        ProviderInterface::ProviderAgreementsController,
        ProviderInterface::ProviderRelationshipPermissionsSetupController,
      ].include?(request.controller_class)
    end

    def requires_make_decisions_permission
      if !current_provider_user.authorisation.can_make_decisions?(
        application_choice: @application_choice,
        course_option_id: @application_choice.current_course_option.id,
      )
        raise ProviderInterface::AccessDenied.new({
          permission: 'make_decisions',
          training_provider: @application_choice.current_course.provider,
          ratifying_provider: @application_choice.current_course.accredited_provider,
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

    def useful_debugging_info
      information = {
        dfe_sign_in_uid: current_provider_user.dfe_sign_in_uid,
        provider_user_admin_url: support_interface_provider_user_url(current_provider_user),
      }

      if (impersonator = current_provider_user.impersonator)
        information[:dfe_sign_in_uid] = impersonator.dfe_sign_in_uid
        information[:support_user_email] = impersonator.email_address
        information[:support_user_admin_url] = support_interface_support_user_url(impersonator)
      end

      information
    end

    def application_support_url
      {
        application_support_url: support_interface_application_form_url(@application_choice.application_form),
      }
    end
  end
end
