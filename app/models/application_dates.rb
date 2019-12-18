class ApplicationDates
  def initialize(application_form)
    @application_form = application_form
  end

  def submitted_at
    @application_form.submitted_at
  end

  def reject_by_default_at
    @application_form.application_choices.first&.reject_by_default_at
  end

  def decline_by_default_at
    @application_form.first_not_declined_application_choice.decline_by_default_at
  end

  def edit_by
    @application_form.application_choices.first&.edit_by
  end

  def days_remaining_to_edit
    edit_by.present? && ((edit_by - Time.zone.now) / 1.day).floor
  end

  def form_open_to_editing?
    edit_by.present? && days_remaining_to_edit >= 1
  end
end
