class SendNewCycleHasStartedEmailToCandidate
  def self.call(application_form:)
    return if already_sent_to?(application_form)

    CandidateMailer.new_cycle_has_started(application_form).deliver_later
    ChaserSent.create!(chased: application_form, chaser_type: :new_cycle_has_started)
  end

  def self.already_sent_to?(application_form)
    application_form.chasers_sent.where(
      chaser_type: :new_cycle_has_started,
    ).where(
      'created_at > ?',
      RecruitmentCycleTimetable.current_timetable.apply_opens_at,
    ).present?
  end
end
