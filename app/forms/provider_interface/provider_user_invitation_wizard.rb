module ProviderInterface
  class ProviderUserInvitationWizard
    include ActiveModel::Model
    STATE_STORE_KEY = :provider_user_invitation_wizard

    attr_accessor :current_step, :current_provider_id, :first_name, :last_name, :email_address, :checking_answers
    attr_writer :providers, :provider_permissions, :state_store

    validates :first_name, presence: true, on: :details
    validates :last_name, presence: true, on: :details
    validates :email_address, presence: true, on: :details
    validates :email_address, email: true, on: :details
    validates :providers, presence: true, on: :providers

    def initialize(state_store, attrs = {})
      @state_store = state_store

      super(JSON.parse(last_saved_state).deep_merge(attrs))
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

    def previous_step
      if checking_answers
        [:check]
      elsif current_step == 'details'
        [:index]
      elsif current_step == 'providers'
        [:details]
      elsif current_step == 'permissions'
        previous_provider_id_with_permissions.present? ? [:permissions, previous_provider_id_with_permissions] : [:providers]
      elsif current_step == 'check'
        [:permissions, previous_provider_id_with_permissions]
      else
        [:check]
      end
    end

    def save!
      raise NotImplementedError, 'Persistence not implemented yet'
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

    def previous_provider_id_with_permissions
      if current_provider_id.present?
        index = provider_permissions.keys.index(current_provider_id)
        index&.positive? ? provider_permissions.keys[index - 1] : nil
      else
        provider_permissions.keys.last
      end
    end
  end
end
