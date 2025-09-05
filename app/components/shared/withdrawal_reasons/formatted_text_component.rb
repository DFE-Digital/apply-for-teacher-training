class WithdrawalReasons::FormattedTextComponent < ApplicationComponent
  OLD_REASONS_PATH = 'config/withdrawal_reasons.yml'.freeze

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
    # No reason given if withdrawn or declined by provider
    if @application_choice.withdrawn_or_declined_for_candidate_by_provider?
      [t('withdrawal_reasons.formatted_text_component.withdrawn_by_provider_on_behalf_of_candidate')]
    # New reason model
    elsif @application_choice.published_withdrawal_reasons.present?
      @application_choice.published_withdrawal_reasons.flat_map do |reason|
        reason_key = reason.reason
        comment = reason.comment

        normalized_reason_key = reason_key.tr('-', '_')
        key = "withdrawal_reasons.formatted_text_component.reasons.#{normalized_reason_key}"

        translation = t(key, default: nil)
        next unless translation

        result = [translation]
        result << %("#{comment}") if comment.present?
        result
      end
    # Old reason model for backward compatibility
    elsif @application_choice.structured_withdrawal_reasons.present?
      @application_choice.structured_withdrawal_reasons.map do |reason_id|
        find_reason_label(reason_id)
      end.compact
    # In the old model, reasons were optional
    else
      [t('withdrawal_reasons.formatted_text_component.no_reason_given')]
    end
  end

  def find_reason_label(reason_id)
    old_reasons.find do |reason|
      reason[:id] == reason_id
    end&.fetch(:label, nil)
  end

  def old_reasons
    YAML.load_file(OLD_REASONS_PATH)
  end
end
