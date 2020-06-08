class GetApplicationChoicesWithNewlyUnavailableCourses
  def self.call
    ApplicationChoice
      .joins(:course_option)
      .where(course_options: { vacancy_status: :no_vacancies })
  end
end
