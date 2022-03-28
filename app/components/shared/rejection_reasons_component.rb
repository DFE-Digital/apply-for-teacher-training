class RejectionReasonsComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :application_choice, :editable, :rejection_reasons

  def initialize(application_choice:, rejection_reasons:, editable: false)
    @application_choice = application_choice
    @rejection_reasons = rejection_reasons
    @editable = editable
  end

  def editable?
    editable
  end

  def paragraphs(input)
    input.split("\r\n")
  end
end
