module ProviderInterface
  class ProviderOptionsService
    attr_reader :provider_user

    def initialize(provider_user)
      @provider_user = provider_user
    end

    def accredited_providers
      Provider
        .joins(:accredited_courses)
        .where(courses: { provider: provider_user.providers, recruitment_cycle_year: })
        .or(
          Provider
            .joins(:accredited_courses)
            .where(courses: { accredited_provider: provider_user.providers, recruitment_cycle_year: }),
        )
        .distinct
    end

    def providers
      Provider
        .joins(:courses)
        .where(courses: { accredited_provider: provider_user.providers, recruitment_cycle_year: })
        .or(
          Provider
            .joins(:courses)
            .where(courses: { provider: provider_user.providers, recruitment_cycle_year: }),
        )
        .distinct
    end

    def providers_with_sites(provider_ids:)
      Provider
        .joins(:courses)
        .where(id: provider_ids)
        .where(courses: { accredited_provider: provider_user.providers, recruitment_cycle_year: })
        .or(
          Provider
            .joins(:courses)
            .where(id: provider_ids)
            .where(courses: { provider: provider_user.providers, recruitment_cycle_year: }),
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

  private

    def recruitment_cycle_year
      RecruitmentCycle.years_visible_to_providers
    end
  end
end
