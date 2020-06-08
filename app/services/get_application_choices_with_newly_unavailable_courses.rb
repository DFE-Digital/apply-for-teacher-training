class GetApplicationChoicesWithNewlyUnavailableCourses
  def self.call
    ApplicationChoice
      .awaiting_references
      .joins(:course_option)
      .where(course_options: { vacancy_status: :no_vacancies })
  end
end
