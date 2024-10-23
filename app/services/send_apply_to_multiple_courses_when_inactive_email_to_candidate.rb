class SendApplyToMultipleCoursesWhenInactiveEmailToCandidate
  def self.call(application_form)
    return if application_form.maximum_number_of_choices_reached?
    return if already_sent_to?(application_form)

    CandidateMailer.apply_to_multiple_courses_after_30_working_days(application_form).deliver_later

    ChaserSent.create!(chased: application_form, chaser_type: :apply_to_multiple_courses_after_30_working_days)
  end

  def self.already_sent_to?(application_form)
    application_form.chasers_sent.where(
      chaser_type: :apply_to_multiple_courses_after_30_working_days,
    ).where('created_at > ?', 1.day.ago).present?
  end
end
