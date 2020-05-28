class SubmitApplicationChoice
  def initialize(application_choice, send_to_provider_immediately: false)
    @application_choice = application_choice
    @send_to_provider_immediately = send_to_provider_immediately
  end

  def call
    ApplicationStateChange.new(@application_choice).submit!

    if @send_to_provider_immediately
      ApplicationStateChange.new(@application_choice).references_complete!
      SendApplicationToProvider.new(application_choice: @application_choice).call
    end

    true
  end
end
