class ApplicationDates
  def initialize(application_form)
    @application_form = application_form
  end

  def submitted_at
    @application_form.submitted_at
  end

  def respond_by
    @application_form.application_choices.first&.reject_by_default_at
  end

  def edit_by
    5.business_days.after(submitted_at).end_of_day
  end

  def days_remaining_to_edit
    ((edit_by - Time.zone.now) / 1.day).floor
  end

  def form_open_to_editing?
    days_remaining_to_edit >= 1
  end
end
