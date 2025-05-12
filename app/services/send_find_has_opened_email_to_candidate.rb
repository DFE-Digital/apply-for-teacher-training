class SendFindHasOpenedEmailToCandidate
  def self.call(application_form:)
    return if already_sent_to?(application_form)

    CandidateMailer.find_has_opened(application_form).deliver_later
    ChaserSent.create!(chased: application_form, chaser_type: :find_has_opened)
  end

  def self.already_sent_to?(application_form)
    application_form.chasers_sent.where(
      chaser_type: :find_has_opened,
    ).where(
      'created_at > ?',
      RecruitmentCycleTimetable.current_timetable.find_opens_at,
    ).present?
  end
end
