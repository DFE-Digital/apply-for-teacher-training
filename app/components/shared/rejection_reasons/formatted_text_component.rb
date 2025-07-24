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
    reasons_data = @application_choice.structured_rejection_reasons['selected_reasons'] || []
    format_reasons(reasons_data)
  end

  def format_reasons(reasons, parent_label = nil)
    formatted = []

    reasons.each do |reason|
      current_label = parent_label ? "#{parent_label} - #{reason['label']}" : reason['label']

      if reason['selected_reasons'].present?
        formatted.concat(format_reasons(reason['selected_reasons'], current_label))
      else
        formatted << current_label
        if reason.dig('details', 'text').present?
          formatted << %("#{reason['details']['text']}")
        end
      end
    end

    formatted
  end
end
