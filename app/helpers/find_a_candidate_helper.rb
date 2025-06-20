module FindACandidateHelper
  def candidate_status(application_form:, provider_user:)
    viewed = provider_user.pool_views.find_by(
      application_form: application_form,
      recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
    )

    invited = Pool::Invite.published.find_by(
      candidate_id: application_form.candidate_id,
      provider_id: provider_user.provider_ids,
      recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
    )

    if invited
      govuk_tag(text: 'Invited', colour: 'green')
    elsif viewed
      govuk_tag(text: 'Viewed', colour: 'grey')
    else
      govuk_tag(text: 'New')
    end
  end
end
