class GetApplicationFormsReadyToDeclineByDefault
  # Returns application forms that have application choices that are due to be
  # declined by default. Because offered application choices always have the same
  # decline by default date, we'll decline all choices with an offer.
  def self.call
    ApplicationForm.where(
      id: ApplicationChoice
        .offer
        .where('decline_by_default_at < ?', Time.zone.now)
        .select(:application_form_id),
    )
  end
end
