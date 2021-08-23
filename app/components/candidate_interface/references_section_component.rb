class CandidateInterface::ReferencesSectionComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :application_form_presenter

  def initialize(application_form_presenter:)
    @application_form_presenter = application_form_presenter
  end
end
