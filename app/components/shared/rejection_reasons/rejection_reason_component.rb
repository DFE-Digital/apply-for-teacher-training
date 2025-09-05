##
# This component class supports the rendering of a single rejection reason predating structured reasons.
#
class RejectionReasons::RejectionReasonComponent < ApplicationComponent
  attr_reader :application_choice

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def reason
    application_choice.rejection_reason
  end
end
