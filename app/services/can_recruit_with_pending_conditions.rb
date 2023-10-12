class CanRecruitWithPendingConditions < HasPendingSkeConditionsOnly
  def call
    application_choice.pending_conditions? &&
      pending_ske_conditions_only? &&
      provider_is_scitt? &&
      course_is_within_time_limit?
  end

private

  def provider_is_scitt?
    application_choice.provider&.scitt?
  end

  def course_is_within_time_limit?
    course_start_date.present? && course_start_date < 3.months.from_now
  end

  def course_start_date
    application_choice.course&.start_date
  end
end
