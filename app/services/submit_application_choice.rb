class SubmitApplicationChoice
  def initialize(application_choice)
    @application_choice = application_choice
  end

  def call
    edit_by_time = time_limit_calculator.call[:time_in_future]
    @application_choice.edit_by = edit_by_time
    ApplicationStateChange.new(@application_choice).submit!
  end

private

  def time_limit_calculator
    klass = HostingEnvironment.sandbox_mode? ? SandboxTimeLimitCalculator : TimeLimitCalculator
    klass.new(
      rule: :edit_by,
      effective_date: @application_choice.application_form.submitted_at,
    )
  end
end
