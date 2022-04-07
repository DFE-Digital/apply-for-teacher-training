class RejectionsComponent < ViewComponent::Base
  attr_reader :application_choice, :editable

  def initialize(application_choice:, editable: false, render_link_to_find_when_rejected_on_qualifications: false)
    @application_choice = application_choice
    @editable = editable
    @render_link_to_find_when_rejected_on_qualifications = render_link_to_find_when_rejected_on_qualifications
  end

  def component_for_rejection_reasons_type
    case @application_choice.rejection_reasons_type
    when 'rejection_reasons'
      RejectionReasons::RejectionReasonsComponent.new(structured_rejection_reasons_attrs)
    when 'reasons_for_rejection'
      RejectionReasons::ReasonsForRejectionComponent.new(structured_rejection_reasons_attrs)
    else
      RejectionReasons::RejectionReasonComponent.new(application_choice: application_choice)
    end
  end

  def structured_rejection_reasons_attrs
    {
      application_choice: application_choice,
      reasons: reasons,
      editable: editable,
      render_link_to_find_when_rejected_on_qualifications: @render_link_to_find_when_rejected_on_qualifications,
    }
  end

  def reasons
    if application_choice.rejection_reasons_type == 'reasons_for_rejection'
      ReasonsForRejection.new(application_choice.structured_rejection_reasons)
    else
      RejectionReasons.from_json_array(application_choice.structured_rejection_reasons)
    end
  end
end
