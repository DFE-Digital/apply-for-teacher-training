class SubmitApplicationChoice
  def initialize(application_choice, send_to_provider_immediately: false)
    @application_choice = application_choice
    @send_to_provider_immediately = send_to_provider_immediately
  end

  def call
    @application_choice.edit_by = if @send_to_provider_immediately
                                    Time.zone.now
                                  else
                                    edit_by_time
                                  end

    ApplicationStateChange.new(@application_choice).submit!

    if @send_to_provider_immediately
      ApplicationStateChange.new(@application_choice).references_complete!
      SendApplicationToProvider.new(application_choice: @application_choice).call
    end

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
