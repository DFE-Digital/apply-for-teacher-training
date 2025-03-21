module ProviderInterface
  class CandidateWithdrawalReasonsDataByProvider
    def initialize(provider)
      @provider = provider
    end

    ReasonRow = Data.define(:reason, :before_accepting, :after_accepting, :total)

    def show_report?
      all_rows.any?
    end

    def all_rows
      return [] if application_form_count < ProviderReports::MINIMUM_DATA_SIZE_REQUIRED

      rows = []
      nested_reasons.each_key do |level_one_reason|
        rows << build_reason_row(level_one_reason, 'level_one')

        nested_reasons[level_one_reason].each_key do |level_two_reason|
          full_level_two_reason = [level_one_reason, level_two_reason].join('.')

          if nested_reasons[level_one_reason][level_two_reason].present?
            rows << build_reason_row(full_level_two_reason, 'level_two_with_nested_reasons')
            nested_reasons[level_one_reason][level_two_reason].each_key do |level_three_reason|
              full_level_three_reason = [level_one_reason, level_two_reason, level_three_reason].join('.')
              rows << build_reason_row(full_level_three_reason, 'level_three')
            end
          else
            rows << build_reason_row(full_level_two_reason, 'level_two')
          end
        end
      end
      rows
    end

  private

    def build_reason_row(reason, level)
      ReasonRow.new(
        reason: {
          text: translate(reason),
          html_attributes: text_cell_attributes_for(level),
        },
        before_accepting: {
          text: before_accepting_count(reason),
          numeric: true,
          html_attributes: numeric_cell_attributes_for(level),
        },
        after_accepting: {
          text: after_accepting_count(reason),
          numeric: true,
          html_attributes: numeric_cell_attributes_for(level),
        },
        total: {
          text: before_accepting_count(reason) + after_accepting_count(reason),
          numeric: true,
          html_attributes: numeric_cell_attributes_for(level),
        },
      )
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

    def before_accepting_count(reason)
      withdrawal_reasons_before_acceptance.filter { |r| r.starts_with?(reason) }.length
    end

    def after_accepting_count(reason)
      withdrawal_reasons_after_acceptance.filter { |r| r.starts_with?(reason) }.length
    end

    def nested_reasons
      @nested_reasons ||= WithdrawalReason.selectable_reasons
    end

    def withdrawal_reasons_before_acceptance
      @withdrawal_reasons_before_acceptance ||=
        withdrawal_reasons
        .where(application_choices: { accepted_at: nil })
        .uniq
        .pluck(:reason)
    end

    def withdrawal_reasons_after_acceptance
      @withdrawal_reasons_after_acceptance ||=
        withdrawal_reasons
          .where.not(application_choices: { accepted_at: nil })
          .uniq
          .pluck(:reason)
    end

    def withdrawal_reasons
      @withdrawal_reasons ||=
        WithdrawalReason
          .joins(:application_choice)
          .published
          .where('application_choices.provider_ids @> ARRAY[?]::bigint[]', @provider.id)
          .where(application_choices: { current_recruitment_cycle_year: RecruitmentCycleTimetable.current_year })
    end

    def application_form_count
      withdrawal_reasons.select('application_choices.application_form_id').distinct.count
    end
  end
end
