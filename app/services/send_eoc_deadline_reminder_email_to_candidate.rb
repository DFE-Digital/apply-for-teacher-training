class SendEocDeadlineReminderEmailToCandidate
  def self.call(application_form:)
    CandidateMailer.eoc_deadline_reminder(application_form)
    ChaserSent.create!(chased: application_form, chaser_type: :eoc_deadline_reminder)
  end
end
