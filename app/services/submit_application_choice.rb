class SubmitApplicationChoice
  def initialize(application_choice, apply_again: false, enough_references: false)
    @application_choice = application_choice
    @apply_again = apply_again
    @enough_references = enough_references
  end

  def call
    if @apply_again && @enough_references
      @application_choice.edit_by = Time.zone.now
      ApplicationStateChange.new(@application_choice).submit!
      ApplicationStateChange.new(@application_choice).references_complete!
    else
      @application_choice.edit_by = edit_by_time
      ApplicationStateChange.new(@application_choice).submit!
    end
  end

private

  def edit_by_time
    if HostingEnvironment.sandbox_mode?
      Time.zone.now
    else
      TimeLimitConfig.edit_by.to_days.after(@application_choice.application_form.submitted_at).end_of_day
    end
  end
end
