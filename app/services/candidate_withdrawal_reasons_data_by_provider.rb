class CandidateWithdrawalReasonsDataByProvider
  attr_reader :generated_at

  def initialize(provider)
    @provider = provider
    @report = provider.withdrawal_reasons_report
    @generated_at = @report&.updated_at
    @statistics = @report&.statistics&.sort_by { |stat| stat['tier_withdrawal_reason'] }
  end

  ReasonRow = Data.define(:reason, :before_accepting, :after_accepting, :total)

  def show_report?
    all_rows.any?
  end

  def all_rows
    return [] if @statistics.blank?

    @statistics.map do |stat|
      build_reason_row(stat)
    end
  end

private

  def build_reason_row(stat)
    ReasonRow.new(
      reason: {
        text: translate(stat['tier_withdrawal_reason']),
        html_attributes: text_cell_attributes_for(level(stat)),
      },
      before_accepting: {
        text: stat['before_accepting'],
        numeric: true,
        html_attributes: numeric_cell_attributes_for(level(stat)),
      },
      after_accepting: {
        text: stat['after_accepting'],
        numeric: true,
        html_attributes: numeric_cell_attributes_for(level(stat)),
      },
      total: {
        text: stat['before_accepting'].to_i + stat['after_accepting'].to_i,
        numeric: true,
        html_attributes: numeric_cell_attributes_for(level(stat)),
      },
    )
  end

  def level(stat)
    case stat['withdrawal_tier']
    when 'tier_1'
      'level_one'
    when 'tier_2'
      nested_tier_2 = @statistics.find do |item|
        item['tier_withdrawal_reason'].start_with?(stat['tier_withdrawal_reason']) &&
          item['withdrawal_tier'] == 'tier_3'
      end.present?

      if nested_tier_2
        'level_two_with_nested_reasons'
      else
        'level_two'
      end

    else
      'level_three'
    end
  end

  def text_cell_attributes_for(level)
    case level
    when 'level_one'
      { class: 'withdrawal-reasons-report-table__cell--main-reason' }
    when 'level_two'
      { class: 'withdrawal-reasons-report-table__cell--second-level-reason' }
    when 'level_two_with_nested_reasons'
      { class: 'withdrawal-reasons-report-table__cell--second-level-with-nested-reasons' }
    when 'level_three'
      { class: 'withdrawal-reasons-report-table__cell--third-level-reason' }
    else
      {}
    end
  end

  def numeric_cell_attributes_for(level)
    case level
    when 'level_one'
      { class: 'withdrawal-reasons-report-table__cell--main-reason' }
    when 'level_two_with_nested_reasons'
      { class: 'withdrawal-reasons-report-table__cell--light-grey-background' }
    else
      {}
    end
  end

  def translate(string)
    translation_string = string.dup.gsub('-', '_')
    I18n.t("candidate_interface.withdrawal_reasons.reasons.#{translation_string}.label")
  end
end
