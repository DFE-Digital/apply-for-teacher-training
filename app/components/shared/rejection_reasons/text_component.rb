class RejectionReasons::TextComponent < ViewComponent::Base
  include ViewHelper

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def render?
    @application_choice.structured_rejection_reasons.present?
  end

  def call
    govuk_list(reasons)
  end

private

  def reasons
    reasons = ::RejectionReasons.new(@application_choice.structured_rejection_reasons).selected_reasons

    return [] if reasons.blank?

    reasons.map do |reason|
      if reason.details&.text.present?
        "#{reason.label}: #{reason.details.text}"
      else
        reason.label
      end
    end
  end
end
