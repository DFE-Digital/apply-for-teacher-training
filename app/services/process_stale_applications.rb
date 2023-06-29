class ProcessStaleApplications
  def initialize
    @application_choices = GetStaleApplicationChoices.call
  end

  def call
    @application_choices.each do |application_choice|
      stale_application_processor(application_choice:).new(application_choice:).call
    end
  end

  def stale_application_processor(application_choice:)
    if application_choice.continuous_applications?
      MarkInactiveApplication
    else
      RejectApplicationByDefault
    end
  end
end
