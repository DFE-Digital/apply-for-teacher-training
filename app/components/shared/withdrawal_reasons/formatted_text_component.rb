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
    @application_choice.published_withdrawal_reasons.flat_map do |reason|
      reason_key = reason.reason
      comment = reason.comment

      normalized_reason_key = reason_key.tr('-', '_')
      key = "withdrawal_reasons.formatted_text_component.reasons.#{normalized_reason_key}"

      translation = t(key, default: nil, comment: comment)

      next unless translation

      [translation, (comment.present? ? %("#{comment}") : nil)]
    end.compact
  end
end
