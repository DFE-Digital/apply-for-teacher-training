module SupportInterface
  class ProviderUsersTableComponent < ActionView::Component::Base
    include ViewHelper

    def initialize(provider_users:)
      @provider_users = provider_users
    end

    def table_rows
      provider_users.map do |provider_user|
        {
          email_address: provider_user.email_address,
          links_to_providers: links_to_providers(provider_user),
          dfe_sign_in_uid: provider_user.dfe_sign_in_uid,
          created_at: provider_user.created_at,
          last_signed_in_at: last_signed_in_at(provider_user),
        }
      end
    end

    def last_signed_in_at(provider_user)
      provider_user.last_signed_in_at&.to_s(:govuk_date_and_time)
    end

    def links_to_providers(provider_user)
      links = provider_user.providers.map do |p|
        govuk_link_to(p.name, support_interface_provider_path(p))
      end

      links.join(', ')
    end

  private

    attr_reader :provider_users
  end
end
