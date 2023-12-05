class ProcessStaleApplications
  def initialize
    @application_choices = GetStaleApplicationChoices.call
  end

  def call
    @application_choices.each do |application_choice|
      MarkInactiveApplication.new(application_choice:).call
    end
  end
end
