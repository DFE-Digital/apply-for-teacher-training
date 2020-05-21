class SubmitApplicationChoice
  def initialize(application_choice, apply_again: false, enough_references: false)
    @application_choice = application_choice
    @apply_again = apply_again
    @enough_references = enough_references
  end

  def call
    @application_choice.edit_by = if @apply_again && @enough_references
                                    Time.zone.now
                                  else
                                    edit_by_time
                                  end

    ApplicationStateChange.new(@application_choice).submit!
    ApplicationStateChange.new(@application_choice).references_complete! if @apply_again && @enough_references
    true
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
