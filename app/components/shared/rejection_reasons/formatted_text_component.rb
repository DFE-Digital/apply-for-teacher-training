class RejectionReasons::FormattedTextComponent < ViewComponent::Base
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

    formatted_reasons = []

    reasons.each do |reason|
      # Output [category] - [reason]
      formatted_reasons << reason.label

      # Output freetext details on a separate line within quotes, if present
      if reason.details&.text.present?
        formatted_reasons << %("#{reason.details.text}")
      end
    end

    formatted_reasons
  end
end
