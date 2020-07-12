module ProviderInterface
  class ProviderUsersInvitationsController < ProviderInterfaceController
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

    def edit_details
      @wizard = ProviderUserInvitationWizard.new(session, current_step: 'details')
      @wizard.save_state!
    end

    def update_details
      @wizard = ProviderUserInvitationWizard.new(session, wizard_params)

      if @wizard.valid_for_current_step?
        @wizard.save_state!
        redirect_to next_redirect(@wizard)
      else
        render :edit_details
      end
    end

    def edit_providers
      @wizard = ProviderUserInvitationWizard.new(session, current_step: 'providers')
      @wizard.save_state!

      @available_providers = current_provider_user.providers
    end

    def update_providers
      @wizard = ProviderUserInvitationWizard.new(session, wizard_params)
      @available_providers = current_provider_user.providers

      if @wizard.valid_for_current_step?
        @wizard.save_state!
        redirect_to next_redirect(@wizard)
      else
        render :edit_providers
      end
    end

    def edit_permissions
      @wizard = ProviderUserInvitationWizard.new(session, current_step: 'permissions')
      @wizard.save_state!

      @permissions_form = ProviderPermissionsForm.new(@wizard.permissions_for(params[:provider_id]))
    end

    def update_permissions
      @wizard = ProviderUserInvitationWizard.new(session, wizard_params)
      @wizard.save_state!

      redirect_to next_redirect(@wizard)
    end

    def check
      @wizard = ProviderUserInvitationWizard.new(session, current_step: 'check')
      @wizard.save_state!
    end

    def commit
      @wizard = ProviderUserInvitationWizard.new(session)
      # wizard.save!
      @wizard.clear_state!

      flash[:success] = 'User successfully invited'
      redirect_to provider_interface_provider_users_path
    end

    def next_redirect(wizard)
      step, provider_id = wizard.next_step

      {
        check: { action: :check },
        providers: { action: :edit_providers },
        permissions: { action: :edit_permissions, provider_id: provider_id },
      }.fetch(step)
    end

    def wizard_params
      params.require(:provider_interface_provider_user_invitation_wizard)
        .permit(:change_answer, :first_name, providers: [], provider_permissions: {})
    end
  end

  class ProviderUserInvitationWizard
    include ActiveModel::Model
    STATE_STORE_KEY = :provider_user_invitation_wizard

    attr_accessor :current_step, :first_name, :checking_answers
    attr_writer :providers, :provider_permissions, :state_store

    validates :first_name, presence: true, on: :details
    validates :providers, presence: true, on: :providers

    def initialize(state_store, attrs = {})
      @state_store = state_store

      super(JSON.parse(last_saved_state).deep_merge(attrs))

      @checking_answers = true if current_step == 'check'
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

    def valid_for_current_step?
      valid?(current_step.to_sym)
    end

    # returns [step, *params] for the next step.
    #
    # this way the wizard is responsible for its own routing
    # but it doesn't need to know about HTTP, so we can test it
    # in isolation
    def next_step
      if checking_answers
        if any_provider_needs_permissions_setup
          [:permissions, next_provider_needing_permissions_setup]
        else
          [:check]
        end
      elsif current_step == 'details'
        [:providers]
      elsif %w[providers permissions].include?(current_step) && any_provider_needs_permissions_setup
        [:permissions, next_provider_needing_permissions_setup]
      else
        [:check]
      end
    end

    def save!
      raise '💾'
    end

    def save_state!
      @state_store[STATE_STORE_KEY] = state
    end

    def clear_state!
      @state_store.delete(STATE_STORE_KEY)
    end

  private

    def state
      as_json(except: %w[state_store errors validation_context]).to_json
    end

    def last_saved_state
      @state_store[STATE_STORE_KEY].presence || '{}'
    end

    def next_provider_needing_permissions_setup
      providers.find { |p| provider_permissions.keys.exclude?(p.to_s) }
    end

    def any_provider_needs_permissions_setup
      next_provider_needing_permissions_setup.present?
    end
  end
end
