module ProviderInterface
  class ProviderUserInvitationWizard
    include ActiveModel::Model
    STATE_STORE_KEY = :provider_user_invitation_wizard

    attr_accessor :current_step, :current_provider_id, :first_name, :last_name, :checking_answers, :single_provider
    attr_reader :email_address
    attr_writer :providers, :provider_permissions, :state_store

    validates :first_name, presence: true, on: :details
    validates :last_name, presence: true, on: :details
    validates :email_address, presence: true, on: :details
    validates :email_address, email: true, on: :details
    validates :providers, presence: true, on: :providers

    PermissionOption = Struct.new(:slug, :name, :hint)
    AVAILABLE_PERMISSIONS = [
      PermissionOption.new(
        'manage_organisations',
        'Manage organisations',
        'Change permissions between organisations',
      ),
      PermissionOption.new(
        'manage_users',
        'Manage users',
        'Invite or delete users and set their permissions',
      ),
      PermissionOption.new(
        'make_decisions',
        'Make decisions',
        'Make offers, amend offers and reject applications',
      ),
      PermissionOption.new(
        'view_safeguarding_information',
        'Access safeguarding information',
        'View sensitive material about the candidate',
      ),
    ].freeze

    class PermissionsForm
      include ActiveModel::Model

      attr_accessor :provider_id, :permissions

      alias_method :id, :provider_id
    end

    def initialize(state_store, attrs = {})
      @state_store = state_store

      super(last_saved_state.deep_merge(attrs))

      self.checking_answers = false if current_step == 'check'
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

    def permissions_for_provider(provider_id)
      provider_permissions[provider_id.to_s]&.dig('permissions') || []
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
        if any_provider_needs_permissions_setup?
          [:permissions, next_provider_needing_permissions_setup]
        else
          [:check]
        end
      elsif current_step == 'details'
        single_provider ? [:permissions, next_provider_id] : [:providers]
      elsif %w[providers permissions].include?(current_step) && next_provider_id.present?
        [:permissions, next_provider_id]
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
        if previous_provider_id.present?
          [:permissions, previous_provider_id]
        else
          single_provider ? [:details] : [:providers]
        end
      elsif current_step == 'check'
        [:permissions, providers.last]
      else
        [:check]
      end
    end

    def save_state!
      @state_store[STATE_STORE_KEY] = state
    end

    def clear_state!
      @state_store.delete(STATE_STORE_KEY)
    end

    def new_user?
      email_address.present? && ProviderUser.find_by(email_address: email_address).nil?
    end

    def email_address=(raw_email_address)
      @email_address = raw_email_address.downcase.strip
    end

  private

    def state
      as_json(except: %w[state_store errors validation_context current_step current_provider_id]).to_json
    end

    def last_saved_state
      JSON.parse(@state_store[STATE_STORE_KEY].presence || '{}')
    end

    def next_provider_id
      if current_provider_id.blank?
        providers.first
      else
        providers.drop_while { |provider_id| provider_id != current_provider_id.to_i }[1]
      end
    end

    def previous_provider_id
      if current_provider_id.blank?
        providers.last
      else
        providers.reverse.drop_while { |provider_id| provider_id != current_provider_id.to_i }[1]
      end
    end

    def next_provider_needing_permissions_setup
      providers.find { |p| provider_permissions.keys.exclude?(p.to_s) }
    end

    def any_provider_needs_permissions_setup?
      next_provider_needing_permissions_setup.present?
    end
  end
end
