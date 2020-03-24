class SubmitApplicationChoice
  def initialize(application_choice)
    @application_choice = application_choice
  end

  def call
    @application_choice.edit_by = edit_by_time
    ApplicationStateChange.new(@application_choice).submit!
  end

private

  def edit_by_time
    if HostingEnvironment.sandbox_mode?
      Time.zone.now
    else
      TimeLimitConfig.edit_by.days.after(@application_choice.application_form.submitted_at).end_of_day
    end
  end
end
