module ProviderInterface
  class ProviderRelationshipPermissionsSetupWizard
    include ActiveModel::Model
    STATE_STORE_KEY = :provider_relationship_permissions_setup_wizard

    attr_accessor :current_step, :current_provider_relationship_id, :checking_answers
    attr_writer :provider_relationships, :provider_relationship_permissions, :state_store

    def initialize(state_store, attrs = {})
      @state_store = state_store

      super(last_saved_state.deep_merge(attrs))

      self.checking_answers = false if current_step == 'check'
    end

    def provider_relationships
      if @provider_relationships
        @provider_relationships.reject(&:blank?).map(&:to_i)
      else
        []
      end
    end

    def provider_relationship_permissions
      @provider_relationship_permissions || {}
    end

    # [provider_relationships info permissions... check]
    def next_step
      if checking_answers
        if any_provider_relationship_needs_permissions_setup?
          [:permissions, next_provider_relationship_needing_permissions_setup]
        else
          [:check]
        end
      elsif current_step == 'provider_relationships'
        [:info]
      elsif current_step == 'info'
        [:permissions, next_provider_relationship_id]
      elsif current_step == 'permissions' && next_provider_relationship_id.present?
        [:permissions, next_provider_relationship_id]
      else
        [:check]
      end
    end

    def previous_step
      if checking_answers
        [:check]
      elsif current_step == 'info'
        [:provider_relationships]
      elsif current_step == 'provider_relationships'
        [:start]
      elsif current_step == 'permissions'
        previous_provider_relationship_id.present? ? [:permissions, previous_provider_relationship_id] : [:info]
      elsif current_step == 'check'
        [:permissions, provider_relationships.last]
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

  private

    def state
      as_json(except: %w[state_store errors validation_context current_step]).to_json
    end

    def last_saved_state
      JSON.parse(@state_store[STATE_STORE_KEY].presence || '{}')
    end

    def next_provider_relationship_id
      if current_provider_relationship_id.blank?
        provider_relationships.first
      else
        provider_relationships.drop_while { |provider_relationship_id| provider_relationship_id != current_provider_relationship_id.to_i }[1]
      end
    end

    def previous_provider_relationship_id
      if current_provider_relationship_id.blank?
        provider_relationships.last
      else
        provider_relationships.reverse.drop_while { |provider_relationship_id| provider_relationship_id != current_provider_relationship_id.to_i }[1]
      end
    end

    def next_provider_relationship_needing_permissions_setup
      ProviderRelationshipPermissions.where(setup_at: nil).order(:created_at)
    end

    def any_provider_relationship_needs_permissions_setup?
      next_provider_relationship_needing_permissions_setup.present?
    end
  end
end
