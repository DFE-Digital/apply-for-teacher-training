class OpenProviderCourses
  attr_reader :provider

  def initialize(provider:)
    @provider = provider
  end

  def call
    if run_courses.or(ratified_courses).update(
      open_on_apply: true,
      opened_on_apply_at: Time.zone.now,
    ).any?
      provider.provider_users.each do |provider_user|
        ProviderMailer.courses_open_on_apply(provider_user)
      end
    end
  end

private

  def run_courses
    @provider.courses
      .current_cycle
      .exposed_in_find
      .includes(:provider)
  end

  def ratified_courses
    @provider.accredited_courses
      .current_cycle
      .exposed_in_find
  end
end
