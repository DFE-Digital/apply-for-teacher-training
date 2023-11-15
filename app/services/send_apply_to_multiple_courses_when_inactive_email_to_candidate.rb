class SendApplyToMultipleCoursesWhenInactiveEmailToCandidate
  def self.call(application_form_id:, application_choices_ids:)
    application_form = ApplicationForm.find(application_form_id)
    return if already_sent_to?(application_form)

    CandidateMailer.apply_to_multiple_courses_after_30_working_days(
      application_choices_ids:,
    ).deliver_later

    ChaserSent.create!(chased: application_form, chaser_type: :apply_to_multiple_courses_after_30_working_days)
  end

  def self.already_sent_to?(application_form)
    application_form.chasers_sent.where(
      chaser_type: :apply_to_multiple_courses_after_30_working_days,
    ).where('created_at > ?', 1.day.ago).present?
  end
end
