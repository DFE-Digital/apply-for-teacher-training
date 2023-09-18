module ApplicationDetailsHelper
  def completed_application_form?(application_form)
    @completed_application_form ||= CandidateInterface::CompletedApplicationForm.new(application_form:).valid?
  end
end
