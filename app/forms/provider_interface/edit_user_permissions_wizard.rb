module ProviderInterface
  class EditUserPermissionsWizard
    include Wizard

    attr_accessor :permissions

    def self.from_model(store, provider_permissions)
      wizard = new(store)

      wizard.permissions ||= valid_permissions_as_string.select do |permission|
        provider_permissions.send(permission)
      end

      wizard
    end

    def show_manage_api_interruption?
      return unless permissions.include?('manage_api_tokens')

      permissions.reject { |c| c.empty? }.sort != valid_permissions_as_string.sort
    end

    private

    def valid_permissions_as_string
      @valid_permissions_as_string ||= ProviderPermissions::VALID_PERMISSIONS.map(&:to_s)
    end
  end
end
