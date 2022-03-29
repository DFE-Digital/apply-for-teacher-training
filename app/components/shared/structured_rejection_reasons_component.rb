class StructuredRejectionReasonsComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :application_choice, :editable

  def initialize(application_choice:, editable: false, render_link_to_find_when_rejected_on_qualifications: false)
    @application_choice = application_choice
    @editable = editable
    @render_link_to_find_when_rejected_on_qualifications = render_link_to_find_when_rejected_on_qualifications
  end

  def reasons
    structured_rejection_reasons_class.new(application_choice.structured_rejection_reasons)
  end

  def component
    component_class.new(
      application_choice: application_choice,
      reasons: reasons,
      editable: editable,
      render_link_to_find_when_rejected_on_qualifications: @render_link_to_find_when_rejected_on_qualifications,
    )
  end

  def component_class
    if @application_choice.rejection_reasons_type == 'rejection_reasons'
      RejectionReasons::RejectionReasonsComponent
    else
      RejectionReasons::ReasonsForRejectionComponent
    end
  end

  def structured_rejection_reasons_class
    if @application_choice.rejection_reasons_type == 'rejection_reasons'
      RejectionReasons
    else
      ReasonsForRejection
    end
  end

  def simple_text_reason?
    application_choice.rejection_reason.present? && application_choice.structured_rejection_reasons.blank?
  end
end
