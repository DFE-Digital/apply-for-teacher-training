class SendEocDeadlineReminderEmailToCandidate
  def self.call(application_form:)
    return if already_sent_to?(application_form)

    CandidateMailer.eoc_deadline_reminder(application_form).deliver_later
    ChaserSent.create!(chased: application_form, chaser_type: :eoc_deadline_reminder)
  end

  def self.already_sent_to?(application_form)
    application_form.chasers_sent.where(
      chaser_type: :eoc_deadline_reminder,
    ).where(
      'created_at > ?',
      CycleTimetable.find_opens,
    ).present?
  end
end
