module SupportInterface
  class ReasonsForRejectionSearchResultsComponent < ViewComponent::Base
    include ViewHelper

    def initialize(search_attribute:, search_value:, application_choices:)
      @search_attribute = search_attribute
      @search_value = search_value
      @application_choices = application_choices
    end

    def search_value_text
      if @search_value == 'Yes'
        i18n_key = SupportInterface::SubReasonsForRejectionTableComponent::TOP_LEVEL_REASONS_TO_I18N_KEYS[@search_attribute].to_s
        t("reasons_for_rejection.#{i18n_key}.title")
      else
        [
          t("reasons_for_rejection.#{@search_attribute}.title"),
          t("reasons_for_rejection.#{@search_attribute}.#{@search_value}"),
        ].join(' - ')
      end
    end

    def sub_reason_text_for(application_choice, top_level_reason)
      sub_reason = sub_reason_for(top_level_reason)
      application_choice
        .structured_rejection_reasons[sub_reason]
        &.map { |value| t("reasons_for_rejection.#{sub_reason}.#{value}") }
        &.join('<br/>')
        &.html_safe
    end

    def reason_text_for(top_level_reason)
      t("reasons_for_rejection.#{sub_reason_for(top_level_reason)}.title")
    end

    def top_level_reason?(reason, value)
      reason =~ /_y_n$/ && value == 'Yes'
    end

  private

    def sub_reason_for(top_level_reason)
      SupportInterface::SubReasonsForRejectionTableComponent::TOP_LEVEL_REASONS_TO_I18N_KEYS[top_level_reason].to_s
    end
  end
end
