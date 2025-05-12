class SendEocDeadlineReminderEmailToCandidate
  # End of cycle chaser_types are :eoc_first_deadline_reminder and :eoc_second_deadline_reminder
  def initialize(application_form:, chaser_type:)
    @application_form = application_form
    @chaser_type = chaser_type
  end

  def call
    return if already_sent_to?

    CandidateMailer.public_send(chaser_type, application_form).deliver_later
    ChaserSent.create!(chased: application_form, chaser_type:)
  end

private

  attr_reader :application_form, :chaser_type

  def already_sent_to?
    application_form
      .chasers_sent
      .where(chaser_type:)
      .where('created_at > ?', find_opens_at).present?
  end

  def find_opens_at
    RecruitmentCycleTimetable.current_timetable.find_opens_at
  end
end
