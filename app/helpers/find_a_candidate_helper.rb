module FindACandidateHelper
  def candidate_status(application_form:)
    if application_form.invited
      govuk_tag(text: 'Invited', colour: 'yellow')
    elsif application_form.viewed
      govuk_tag(text: 'Viewed', colour: 'grey')
    else
      govuk_tag(text: 'New')
    end
  end
end
