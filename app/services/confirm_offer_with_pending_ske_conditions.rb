class ConfirmOfferWithPendingSkeConditions < ConfirmOfferConditions
  def save
    auth.assert_can_make_decisions!(
      application_choice:,
      course_option_id: application_choice.current_course_option.id,
    )

    audit(auth.actor) do
      ApplicationStateChange.new(application_choice).recruit_with_pending_conditions!
      application_choice.update!(recruited_at: Time.zone.now)
      CandidateMailer.conditions_met(application_choice).deliver_later
    end

    true
  rescue Workflow::NoTransitionAllowed
    errors.add(
      :base,
      I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
    )
    false
  end
end
