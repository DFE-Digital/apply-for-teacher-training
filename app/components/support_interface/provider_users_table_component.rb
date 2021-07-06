module SupportInterface
  class ProviderUsersTableComponent < ViewComponent::Base
    include ViewHelper

    def initialize(provider_users:)
      @provider_users = provider_users
    end

    def table_rows
      provider_users.sort_by(&:last_name).map do |provider_user|
        {
          provider_user: provider_user,
          created_at: provider_user.created_at,
          last_signed_in_at: last_signed_in_at(provider_user),
        }
      end
    end

    def last_signed_in_at(provider_user)
      provider_user.last_signed_in_at&.to_s(:govuk_date_and_time)
    end

    def render?
      provider_users.any?
    end

  private

    attr_reader :provider_users
  end
end
