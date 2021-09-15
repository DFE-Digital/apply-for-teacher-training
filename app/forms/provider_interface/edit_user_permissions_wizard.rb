module ProviderInterface
  class EditUserPermissionsWizard
    include Wizard

    attr_accessor :permissions

    def initialize(state_store, attrs = {})
      @state_store = state_store

      super(last_saved_state.deep_merge(attrs))
    end

    def self.from_model(store, provider_permissions)
      wizard = new(store)

      wizard.permissions ||= ProviderPermissions::VALID_PERMISSIONS.map(&:to_s).select do |permission|
        provider_permissions.send(permission)
      end

      wizard
    end
  end
end
