##
# This component class supports the rendering of all the various formats of reasons for rejection.
# See https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/docs/reasons-for-rejection.md
#
class RejectionsComponent < ViewComponent::Base
  attr_reader :application_choice

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def component_for_rejection_reasons_type
    case @application_choice.rejection_reasons_type
    when 'rejection_reasons', 'vendor_api_rejection_reasons'
      RejectionReasons::RejectionReasonsComponent.new(**structured_rejection_reasons_attrs)
    when 'reasons_for_rejection'
      RejectionReasons::ReasonsForRejectionComponent.new(**structured_rejection_reasons_attrs)
    else
      RejectionReasons::RejectionReasonComponent.new(application_choice:)
    end
  end

private

  def structured_rejection_reasons_attrs
    { application_choice:, reasons: }
  end

  def reasons
    if application_choice.rejection_reasons_type == 'reasons_for_rejection'
      ::ReasonsForRejection.new(application_choice.structured_rejection_reasons)
    else
      ::RejectionReasons.new(application_choice.structured_rejection_reasons)
    end
  end
end
