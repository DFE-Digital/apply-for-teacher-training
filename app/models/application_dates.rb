class ApplicationDates
  def initialize(application_form)
    @application_form = application_form
  end

  def submitted_at
    @application_form.submitted_at
  end

  def respond_by
    submitted_at + 40.days
  end

  def edit_by
    submitted_at + 7.days
  end

  def days_remaining_to_edit
    (submitted_at.to_date + 7.days - Time.now.to_date).to_i
  end

  def form_open_to_editing?
    days_remaining_to_edit >= 1
  end
end
