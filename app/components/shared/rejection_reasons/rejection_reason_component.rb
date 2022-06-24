##
# This component class supports the rendering of a single rejection reason predating structured reasons.
#
class RejectionReasons::RejectionReasonComponent < ViewComponent::Base
  attr_reader :application_choice

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def reason
    if application_choice.offer_withdrawn?
      application_choice.offer_withdrawal_reason
    else
      application_choice.rejection_reason
    end
  end
end
