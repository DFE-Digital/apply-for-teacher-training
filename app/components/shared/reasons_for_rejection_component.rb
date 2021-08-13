class ReasonsForRejectionComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :application_choice, :editable, :reasons_for_rejection

  def initialize(application_choice:, reasons_for_rejection:, editable: false, render_link_to_find_when_rejected_on_qualifications: false)
    @application_choice = application_choice
    @reasons_for_rejection = reasons_for_rejection
    @editable = editable
    @render_link_to_find_when_rejected_on_qualifications = render_link_to_find_when_rejected_on_qualifications
  end

  def editable?
    editable
  end

  def subheading_tag_name
    editable? ? :h2 : :h3
  end
end
