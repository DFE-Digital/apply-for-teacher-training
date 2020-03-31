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
            .where(courses: { accrediting_provider: provider_user.providers }),
        )
        .distinct
    end

    def providers
      Provider
        .joins(:courses)
        .where(courses: { accrediting_provider: provider_user.providers })
        .or(
          Provider
            .joins(:courses)
            .where(courses: { provider: provider_user.providers }),
        )
        .distinct
    end
  end
end
