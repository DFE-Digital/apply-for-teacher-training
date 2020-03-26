class ProviderOptionsService
  attr_reader :provider_user

  def initialize(provider_user)
    @provider_user = provider_user
  end

  def accrediting_providers
    Provider
      .joins(:accredited_courses)
      .where(courses: { provider: provider_user.providers })
      .distinct
  end
end
