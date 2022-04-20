##
# This component class supports the rendering of a single rejection reason predating structured reasons.
#
class RejectionReasons::RejectionReasonComponent < ViewComponent::Base
  attr_reader :application_choice, :reason

  def initialize(application_choice:)
    @application_choice = application_choice
    @reason = application_choice.rejection_reason
  end
end
