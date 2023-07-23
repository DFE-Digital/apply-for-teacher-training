class GetAvailableCoursesForProvider
  attr_reader :provider

  def initialize(provider)
    @provider = provider
  end

  # provider
  #  .courses
  #  .current_cycle
  #  .exposed_in_find
  #  .left_outer_joins(:course_options)
  #  .where(:'course_options.site_still_valid' => true)
  #  .where(:'course_options.vacancy_status' => 'vacancies')
  #  .order(:name)
  def call
    courses_for_current_cycle
      .exposed_in_find
      .includes(:accredited_provider, :course_options)
      .order(:name)
  end

  def courses_for_current_cycle
    provider.courses.current_cycle
  end
end
