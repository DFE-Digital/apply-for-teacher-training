class ApplicationDates
  def initialize(application_form)
    @application_form = application_form
  end

  def submitted_at
    @application_form.submitted_at
  end

  def respond_by
    40.business_days.after(submitted_at)
  end

  def edit_by
    7.business_days.after(submitted_at)
  end

  def days_remaining_to_edit
    (edit_by - Time.now.to_date).to_i
  end

  def form_open_to_editing?
    days_remaining_to_edit >= 1
  end
end
