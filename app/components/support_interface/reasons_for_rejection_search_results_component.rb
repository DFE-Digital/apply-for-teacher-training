module SupportInterface
  class ReasonsForRejectionSearchResultsComponent < ApplicationComponent
    include ViewHelper

    def initialize(search_attribute:, search_value:, application_choices:)
      @search_attribute = search_attribute
      @search_value = search_value
      @application_choices = application_choices
    end

    def summary_list_rows_for(application_choice)
      selected_reasons = Array(
        application_choice.structured_rejection_reasons['selected_reasons'],
      )

      selected_reasons.map do |reason|
        key = reason['id']
        value = reason_text_for(reason)

        {
          key: mark_search_term(key.titleize, key == @search_value),
          value: value,
        }
      end.compact
    end

    def search_title_text
      @search_value.titleize
    end

  private

    def reason_text_for(reason)
      if reason['details'].present?
        reason['details']['text']
      elsif reason['selected_reasons'].present?
        values = Array(reason['selected_reasons']).map do |sub_reason|
          reason_text_for(sub_reason)
        end

        values_as_list(values)
      else
        reason['label']
      end
    end

    def mark_search_term(text, mark)
      mark ? "<mark>#{text}</mark>".html_safe : text
    end

    def values_as_list(values)
      return nil if values.blank?
      return values[0] if values.size == 1

      tag.ul(
        values.map { |value| tag.li(value) }.join.html_safe,
        class: 'govuk-list govuk-list--bullet govuk-!-margin-left-0 govuk-!-margin-right-0',
      ).html_safe
    end
  end
end
