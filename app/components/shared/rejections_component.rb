##
# This component class supports the rendering of all the various formats of reasons for rejection.
# See https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/docs/app_concepts/reasons-for-rejection.md
#
class RejectionsComponent < ApplicationComponent
  attr_reader :application_choice

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def component_for_rejection_reasons_type
    case @application_choice.rejection_reasons_type
    when 'rejection_reasons', 'vendor_api_rejection_reasons'
      RejectionReasons::RejectionReasonsComponent.new(application_choice:)
    when 'reasons_for_rejection'
      RejectionReasons::ReasonsForRejectionComponent.new(application_choice:)
    else
      RejectionReasons::RejectionReasonComponent.new(application_choice:)
    end
  end
end
