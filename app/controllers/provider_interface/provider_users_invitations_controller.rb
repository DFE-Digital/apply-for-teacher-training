module ProviderInterface
  class ProviderUsersInvitationsController < ProviderInterfaceController
    WIZARD_STATE_SESSION_KEY = :provider_user_invitation_wizard

    class ProviderPermissionsForm
      include ActiveModel::Model

      Permission = Struct.new(:slug, :name)

      attr_accessor :provider_id, :permissions

      def available_permissions
        [
          Permission.new('manage_users', 'Manage users'),
          Permission.new('make_decisions', 'Make decisions'),
        ]
      end

      def provider
        Provider.find(provider_id)
      end

      alias_method :id, :provider_id
    end

    def wizard_state
      { _state: session[WIZARD_STATE_SESSION_KEY].presence || {} }
    end

    def save_wizard_state!
      session[WIZARD_STATE_SESSION_KEY] = @wizard.state
    end

    def clear_wizard_state!
      session.delete(WIZARD_STATE_SESSION_KEY)
    end

    def edit_details
      @wizard = ProviderUserInvitationWizard.new(wizard_state.merge(current_step: 'details', returning_to_answered_question: params[:change]))
      save_wizard_state!
    end

    def update_details
      @wizard = ProviderUserInvitationWizard.new(wizard_state.merge(wizard_params))

      if @wizard.valid_for_current_step?
        save_wizard_state!
        redirect_to next_redirect(@wizard)
      else
        render :edit_details
      end
    end

    def edit_providers
      @wizard = ProviderUserInvitationWizard.new(wizard_state.merge(current_step: 'providers', returning_to_answered_question: params[:change]))
      save_wizard_state!

      @available_providers = current_provider_user.providers
    end

    def update_providers
      @wizard = ProviderUserInvitationWizard.new(wizard_state.merge(wizard_params))
      @available_providers = current_provider_user.providers

      if @wizard.valid_for_current_step?
        save_wizard_state!
        redirect_to next_redirect(@wizard)
      else
        render :edit_providers
      end
    end

    def edit_permissions
      @wizard = ProviderUserInvitationWizard.new(wizard_state.merge(current_step: 'permissions', returning_to_answered_question: params[:change]))
      save_wizard_state!

      @permissions_form = ProviderPermissionsForm.new(@wizard.permissions_for(params[:provider_id]))
    end

    def update_permissions
      @wizard = ProviderUserInvitationWizard.new(wizard_state.merge(wizard_params))
      save_wizard_state!

      redirect_to next_redirect(@wizard)
    end

    def check
      @wizard = ProviderUserInvitationWizard.new(wizard_state.merge(current_step: 'check'))
    end

    def commit
      @wizard = ProviderUserInvitationWizard.new(wizard_state)

      clear_wizard_state!

      flash[:success] = 'User successfully invited'
      redirect_to provider_interface_provider_users_path
    end

    def next_redirect(wizard)
      if wizard.returning_to_answered_question
        if wizard.has_permissions_to_set?
          { action: :edit_permissions, provider_id: wizard.next_provider_requiring_permissions_setup }
       else # carry on back to the check answers page
          { action: :check }
        end
      elsif wizard.current_step == 'details'
        { action: :edit_providers }
      elsif wizard.current_step == 'providers' && wizard.has_permissions_to_set?
        { action: :edit_permissions, provider_id: wizard.next_provider_requiring_permissions_setup }
      elsif wizard.current_step == 'permissions' && wizard.has_permissions_to_set?
        { action: :edit_permissions, provider_id: wizard.next_provider_requiring_permissions_setup }
      else
        { action: :check }
      end
    end

    def wizard_params
      params.require(:provider_interface_provider_user_invitation_wizard)
        .permit(:change_answer, :first_name, providers: [], provider_permissions: {})
    end
  end

  class ProviderUserInvitationWizard
    include ActiveModel::Model

    attr_accessor :current_step, :first_name, :returning_to_answered_question
    attr_writer :providers, :provider_permissions, :_state

    validates :first_name, presence: true, on: :details
    validates :providers, presence: true, on: :providers

    def initialize(attrs)
      state = attrs[:_state].presence || '{}'
      attrs_incl_state = JSON.parse(state).deep_merge(attrs)
      super(attrs_incl_state)
    end

    def valid_for_current_step?
      valid?(current_step.to_sym)
    end

    def save!
      raise '💾'
    end

    def state
      as_json(except: %w[_state change_answer errors validation_context]).to_json
    end

    def providers
      if @providers
        @providers.reject(&:blank?).map(&:to_i)
      else
        []
      end
    end

    def provider_permissions
      @provider_permissions || {}
    end

    def applicable_provider_permissions
      @provider_permissions.select do |id, _details|
        providers.include?(id.to_i)
      end
    end

    def permissions_for(provider_id)
      provider_permissions[provider_id].presence || { provider_id: provider_id, permissions: [] }
    end

    def next_provider_requiring_permissions_setup
      providers.find { |p| provider_permissions.keys.exclude?(p.to_s) }
    end

    def has_permissions_to_set?
      next_provider_requiring_permissions_setup.present?
    end
  end
end
