class ApplicationDates
  def initialize(application_form)
    @application_form = application_form
  end

  def submitted_at
    first_pending_condition = @application_form.application_choices.pending_conditions.first

    first_pending_condition&.sent_to_provider_at || @application_form.submitted_at
  end

  def reject_by_default_at
    @application_form.application_choices.first&.reject_by_default_at
  end
end
