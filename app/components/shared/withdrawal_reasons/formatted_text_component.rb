class WithdrawalReasons::FormattedTextComponent < ViewComponent::Base
  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def render?
    @application_choice.withdrawn?
  end

  def call
    govuk_list(reasons)
  end

private

  def reasons
    @application_choice.published_withdrawal_reasons.map do |reason|
      reason_key = reason.reason
      comment = reason.comment

      parts = reason_key.downcase.split('.').map { |p| p.tr('-', '_') }

      # Separate the last part as the specific reason
      reason_label = parts.last.humanize
      category_label = parts.first.humanize

      # Final formatted string
      label = "#{category_label} - #{reason_label}"

      # Return reason + optional quoted comment as two separate lines
      [label, (comment.present? ? %("#{comment}") : nil)]
    end.flatten.compact
  end
end
