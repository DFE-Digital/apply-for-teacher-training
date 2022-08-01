class NewReferencesFeature
  attr_reader :application_form
  OLD_REFERENCE_FLOW_CYCLE_YEAR = 2022

  def initialize(application_form)
    @application_form = application_form
  end

  def active?
    FeatureFlag.active?(:new_references_flow) && application_form.recruitment_cycle_year > OLD_REFERENCE_FLOW_CYCLE_YEAR
  end

  def inactive?
    application_form.recruitment_cycle_year <= OLD_REFERENCE_FLOW_CYCLE_YEAR
  end
end
