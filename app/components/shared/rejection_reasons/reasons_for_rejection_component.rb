class RejectionReasons::ReasonsForRejectionComponent < ViewComponent::Base
  include ViewHelper
  include RejectionReasons::ComponentHelper

  attr_reader :application_choice, :editable, :reasons

  def initialize(application_choice:, reasons:, editable: false, render_link_to_find_when_rejected_on_qualifications: false)
    @application_choice = application_choice
    @reasons = reasons
    @editable = editable
    @render_link_to_find_when_rejected_on_qualifications = render_link_to_find_when_rejected_on_qualifications
  end
end
