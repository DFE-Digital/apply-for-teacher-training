module SupportInterface
  class ProvidersNavigationComponent < ApplicationComponent
    include ViewHelper

  private

    def items
      items = [
        { name: 'Providers', url: support_interface_providers_path },
        { name: 'API tokens', url: support_interface_api_tokens_path, current: api_tokens_path? },
        { name: 'Provider users', url: support_interface_provider_users_path },
      ]

      items << { name: 'Personas', url: support_interface_personas_path } if HostingEnvironment.test_environment?
      items << { name: 'Reports', url: support_interface_reports_path, current: reports? }

      items
    end

    def api_tokens_path?
      request.path.include?('support/token')
    end

    def reports?
      request.path.include?('provider-recruitment-report') ||
        request.path.include?('status-of-active-applications') ||
        request.path.include?('withdrawal-reasons-report')
    end
  end
end
