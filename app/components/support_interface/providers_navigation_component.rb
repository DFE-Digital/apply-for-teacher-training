module SupportInterface
  class ProvidersNavigationComponent < ApplicationComponent
    include ViewHelper

  private

    def items
      items = []
      if SupportInterface::ProviderPolicy.new(helpers.current_support_user, nil).show?
        items << { name: 'Providers', url: support_interface_providers_path }
        items << { name: 'API tokens', url: support_interface_api_tokens_path, current: api_tokens_path? }
      end
      if SupportInterface::ProviderUserPolicy.new(helpers.current_support_user, nil).show?
        items << { name: 'Provider users', url: support_interface_provider_users_path }
      end

      items << { name: 'Personas', url: support_interface_personas_path } if HostingEnvironment.test_environment?

      items
    end

    def api_tokens_path?
      request.path.include?('support/token')
    end
  end
end
