# NOTE: This component is used by both provider and support UIs
class ChoicePersonalStatementComponent < ViewComponent::Base
  include ViewHelper

  delegate :personal_statement,
           to: :application_choice

  def initialize(application_choice:, editable: false)
    @application_choice = application_choice
    @editable = editable
  end

private

  attr_reader :application_choice
end
