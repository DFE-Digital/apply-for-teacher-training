module SupportInterface
  class ReasonsForRejectionSearchResultsComponent < ViewComponent::Base
    include ViewHelper

    def initialize(search_attribute:, search_value:, application_choices:)
      @search_attribute = search_attribute
      @search_value = search_value
      @application_choices = application_choices
    end

    def summary_list_rows_for(application_choice)
      application_choice.structured_rejection_reasons.map do |reason, value|
        reason_detail_text = reason_detail_text_for(application_choice, reason)
        next unless top_level_reason?(reason, value) && reason_detail_text.presence

        {
          key: reason_text_for(reason),
          value: reason_detail_text,
        }
      end.compact
    end

    def search_title_text
      if @search_value == 'Yes'
        i18n_key = ReasonsForRejection::TOP_LEVEL_REASONS_TO_I18N_KEYS[@search_attribute].to_s
        translated_search_title(i18n_key)
      else
        top_level_reason = ReasonsForRejectionCountQuery::SUBREASONS_TO_TOP_LEVEL_REASONS[@search_attribute.to_sym]
        i18n_key = ReasonsForRejection::TOP_LEVEL_REASONS_TO_I18N_KEYS[top_level_reason].to_s
        [
          translated_search_title(i18n_key),
          t("reasons_for_rejection.#{i18n_key}.#{@search_value}", default: ''),
        ].join(' - ')
      end
    end

    def reason_detail_text_for(application_choice, top_level_reason)
      sub_reason = sub_reason_for(top_level_reason)
      if sub_reason.present?
        values_as_list(
          application_choice.structured_rejection_reasons[sub_reason]
            &.map { |value| sub_reason_detail_text(application_choice, top_level_reason, sub_reason, value) }
            &.reject(&:blank?),
        )
      else
        detail_reason_for(application_choice, top_level_reason)
      end
    end

    def sub_reason_detail_text(application_choice, top_level_reason, sub_reason, value)
      i18n_key = ReasonsForRejection::TOP_LEVEL_REASONS_TO_I18N_KEYS[top_level_reason].to_s
      text = mark_search_term(
        I18n.t("reasons_for_rejection.#{i18n_key}.#{value}", default: ''),
        value.to_s == @search_value.to_s,
      )

      detail_questions = ReasonsForRejection::INITIAL_QUESTIONS.dig(
        top_level_reason.to_sym, sub_reason.to_sym, value.to_sym
      )
      additional_text =
        if detail_questions.is_a?(Array)
          values_as_list(
            detail_questions.map { |detail_question| application_choice.structured_rejection_reasons[detail_question.to_s] }.compact,
          )
        else
          application_choice.structured_rejection_reasons[detail_questions.to_s]
        end

      [text, additional_text].reject(&:blank?).join(' - ').html_safe
    end

    def reason_text_for(top_level_reason)
      i18n_key = ReasonsForRejection::TOP_LEVEL_REASONS_TO_I18N_KEYS[top_level_reason].to_s
      mark_search_term(translated_search_title(i18n_key), top_level_reason.to_s == @search_attribute.to_s)
    end

    def top_level_reason?(reason, value)
      return true if other_reasons_question?(reason)

      ReasonsForRejection::TOP_LEVEL_REASONS_TO_I18N_KEYS.key?(reason) &&
        value == 'Yes'
    end

  private

    def values_as_list(values)
      return nil if values.blank?
      return values[0] if values.size == 1

      tag.ul(
        values.map { |value| tag.li(value) }.join.html_safe,
        class: 'govuk-list govuk-list--bullet govuk-!-margin-left-0 govuk-!-margin-right-0',
      ).html_safe
    end

    def mark_search_term(text, mark)
      mark ? "<mark>#{text}</mark>".html_safe : text
    end

    def sub_reason_for(top_level_reason)
      ReasonsForRejectionCountQuery::TOP_LEVEL_REASONS_TO_SUB_REASONS[top_level_reason.to_sym].to_s
    end

    def detail_reason_for(application_choice, top_level_reason)
      detail_questions = ReasonsForRejection::ALL_QUESTIONS[top_level_reason.to_sym]&.keys || []
      detail_questions << top_level_reason if other_reasons_question?(top_level_reason)
      return 'Yes' if detail_questions.empty?

      values_as_list(
        detail_questions.map { |detail_question| application_choice.structured_rejection_reasons[detail_question.to_s] }.compact,
      )
    end

    def other_reasons_question?(question_key)
      question_key == ReasonsForRejection::OTHER_REASON.to_s
    end

    def translated_search_title(i18n_key)
      t("reasons_for_rejection.#{i18n_key}.alt_title", default: t("reasons_for_rejection.#{i18n_key}.title", default: ''))
    end
  end
end
