module ProviderInterface
  class ProviderAccountComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :current_provider_user

    def initialize(current_provider_user:)
      @current_provider_user = current_provider_user
    end

    def rows
      [
        { key: 'First name', value: current_provider_user.first_name },
        { key: 'Last name', value: current_provider_user.last_name },
        { key: 'Email address', value: current_provider_user.email_address },
        organisations_row,
        permissions_rows,
      ].flatten
    end

    def dsi_profile_url
      return 'https://test-profile.signin.education.gov.uk' if HostingEnvironment.qa?

      'https://profile.signin.education.gov.uk'
    end

  private

    def organisations_row
      {
        key: 'Organisations you have access to',
        value: organisations,
      }
    end

    def organisations
      current_provider_user.providers.map(&:name)
    end

    def permissions_rows
      current_provider_user.provider_permissions.includes([:provider]).map do |permission|
        {
          key: "Permissions: #{permission.provider.name}",
          value: render(PermissionsList.new(permission)),
        }
      end
    end
  end
end
