class CandidateInterface::GcseRequirementsComponent < ViewComponent::Base
  include ViewHelper

  attr_accessor :application_choice

  def initialize(application_choice)
    @application_choice = application_choice
  end
end
