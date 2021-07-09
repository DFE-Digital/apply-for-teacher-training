module ProviderInterface
  class OrganisationPermissionsSetupListComponent < ViewComponent::Base
    attr_reader :grouped_provider_names, :continue_button_path

    def initialize(grouped_provider_names:, continue_button_path:)
      @grouped_provider_names = grouped_provider_names
      @continue_button_path = continue_button_path
    end

    def multiple_providers_to_set_up?
      @multiple_providers_to_set_up ||= grouped_provider_names.length > 1
    end
  end
end
