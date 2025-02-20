class ProviderInterface::FindCandidates::RightToWorkComponent < ViewComponent::Base
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def visa_sponsorhip_value
    application_form.right_to_work_or_study_yes? ? 'Not required' : 'Required'
  end
end
