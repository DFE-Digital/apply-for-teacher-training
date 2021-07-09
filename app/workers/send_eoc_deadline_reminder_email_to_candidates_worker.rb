class SendEocDeadlineReminderEmailToCandidatesWorker
  include Sidekiq::Worker

  def perform
    applications_to_send_reminders_to.each do |application|
      SendEocDeadlineReminderEmailToCandidate.call(application_form: application)
    end
  end

  def applications_to_send_reminders_to
    return [] unless CycleTimetable.need_to_send_deadline_reminder?

    if CycleTimetable.need_to_send_deadline_reminder? == :apply_1
      ApplicationForm
        .current_cycle
        .where(submitted_at: nil)
        .where(phase: 'apply_1')
    elsif CycleTimetable.need_to_send_deadline_reminder? == :apply_2
      ApplicationForm
      .current_cycle
      .where(submitted_at: nil)
      .where(phase: 'apply_2')
    end
  end
end
