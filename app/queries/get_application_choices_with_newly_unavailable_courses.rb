class GetApplicationChoicesWithNewlyUnavailableCourses
  def self.call
    ApplicationChoice
      .awaiting_references
      .joins(:course_option)
      .joins("LEFT OUTER JOIN chasers_sent ON chasers_sent.chased_id = application_choices.id AND chasers_sent.chased_type = 'ApplicationChoice' AND chasers_sent.chaser_type = 'course_unavailable_notification'")
      .where(course_options: { vacancy_status: :no_vacancies })
      .where(chasers_sent: { id: nil })
  end
end
