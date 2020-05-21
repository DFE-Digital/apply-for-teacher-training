module ProviderInterface
  class ProviderOptionsService
    attr_reader :provider_user

    def initialize(provider_user)
      @provider_user = provider_user
    end

    def accredited_providers
      Provider
        .joins(:accredited_courses)
        .where(courses: { provider: provider_user.providers })
        .or(
          Provider
            .joins(:accredited_courses)
            .where(courses: { accredited_provider: provider_user.providers }),
        )
        .distinct
    end

    def providers
      Provider
        .joins(:courses)
        .where(courses: { accredited_provider: provider_user.providers })
        .or(
          Provider
            .joins(:courses)
            .where(courses: { provider: provider_user.providers }),
        )
        .distinct
    end

    # TODO: Write test from this in provider_options_service_spec
    def providers_with_sites
      Provider
        .joins(:courses)
        .where(courses: { accredited_provider: provider_user.providers })
        .or(
          Provider
            .joins(:courses)
            .where(courses: { provider: provider_user.providers }),
        )
        .includes([:sites]).distinct
    end

    def providers_with_manageable_users
      Provider
        .joins(provider_permissions: :provider_user)
          .where(ProviderPermissions.table_name => {
            provider_user_id: provider_user.id,
            manage_users: true,
          })
        .order(name: :asc)
    end
  end
end
