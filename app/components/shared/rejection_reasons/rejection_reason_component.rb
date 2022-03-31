class RejectionReasons::RejectionReasonComponent < ViewComponent::Base
  include RejectionReasons::ComponentHelper

  attr_reader :application_choice, :reason

  def initialize(application_choice:)
    @application_choice = application_choice
    @reason = application_choice.rejection_reason
  end
end
