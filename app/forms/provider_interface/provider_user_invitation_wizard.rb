module ProviderInterface
  class ProviderUserInvitationWizard
    include ActiveModel::Model
    STATE_STORE_KEY = :provider_user_invitation_wizard

    attr_accessor :current_step, :current_provider_id, :first_name, :last_name, :checking_answers, :single_provider
    attr_reader :email_address
    attr_writer :providers, :provider_permissions, :state_store

    with_options(on: :details) do
      validates :email_address, presence: true
      validates :email_address, valid_for_notify: true
      validates :first_name, presence: true
      validates :last_name, presence: true
    end

    validates :providers, presence: true, on: :providers

    validate :permission_form_is_valid, on: :permissions

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

    def permissions_form
      @_permissions_form ||= FieldsForProviderUserPermissionsForm.new(permissions_for(current_provider_id))
    end

    def valid_for_current_step?
      valid?(current_step.to_sym)
    end

    # returns [step, *params] for the next step.
    #
    # this way the wizard is responsible for its own routing
    # but it does not need to know about HTTP, so we can test it
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
      @state_store.write(state)
    end

    def clear_state!
      @state_store.delete
    end

    def new_user?
      email_address.present? && ProviderUser.find_by(email_address: email_address).nil?
    end

    def email_address=(raw_email_address)
      @email_address = raw_email_address.downcase.strip
    end

  private

    def permission_form_is_valid
      return if permissions_form.valid?

      permissions_form.errors.each do |error|
        errors.add("provider_permissions[#{permissions_form.id}][#{error.attribute}]", error.message)
      end
    end

    def state
      as_json(except: %w[state_store errors validation_context current_step current_provider_id _permissions_form]).to_json
    end

    def last_saved_state
      saved_state = @state_store.read

      if saved_state
        JSON.parse(saved_state)
      else
        {}
      end
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
