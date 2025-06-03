class GetAvailableCoursesForProvider
  attr_reader :provider

  def initialize(provider)
    @provider = provider
  end

  def call
    courses_for_current_cycle
      .exposed_in_find
      .includes(:accredited_provider, :course_options)
      .order(:name)
  end

  def courses_for_current_cycle
    provider.courses.current_cycle
  end

  def open_courses
    courses_for_current_cycle.open
      .includes(:accredited_provider, :course_options)
      .order(:name)
  end
end
