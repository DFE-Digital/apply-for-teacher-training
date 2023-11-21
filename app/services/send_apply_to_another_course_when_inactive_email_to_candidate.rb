class SendApplyToAnotherCourseWhenInactiveEmailToCandidate
  def self.call(application_form)
    return if already_sent_to?(application_form)

    CandidateMailer.apply_to_another_course_after_30_working_days(application_form).deliver_later

    ChaserSent.create!(chased: application_form, chaser_type: :apply_to_another_course_after_30_working_days)
  end

  def self.already_sent_to?(application_form)
    application_form.chasers_sent.where(
      chaser_type: :apply_to_another_course_after_30_working_days,
    ).where('created_at > ?', 1.day.ago).present?
  end
end
