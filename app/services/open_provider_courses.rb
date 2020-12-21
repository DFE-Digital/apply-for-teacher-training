class OpenProviderCourses
  attr_reader :provider

  def initialize(provider:)
    @provider = provider
  end

  def call
    if provider.courses.current_cycle.exposed_in_find.update_all(open_on_apply: true).positive?
      provider.provider_users.each do |provider_user|
        ProviderMailer.courses_open_on_apply(provider_user)
      end
    end
  end
end
