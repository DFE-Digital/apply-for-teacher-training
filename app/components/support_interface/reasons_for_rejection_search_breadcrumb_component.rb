module SupportInterface
  class ReasonsForRejectionSearchBreadcrumbComponent < ViewComponent::Base
    include ViewHelper

    def initialize(search_attribute:, search_value:)
      @search_attribute = search_attribute
      @search_value = search_value
    end

    def breadcrumb_items
      breadcrumb_items = {
        'Performance': support_interface_performance_path,
        'Structured reasons for rejection': support_interface_reasons_for_rejection_dashboard_path,
      }
      if top_level_reason?
        i18n_key = ReasonsForRejection::TOP_LEVEL_REASONS_TO_I18N_KEYS[@search_attribute].to_s
        breadcrumb_items[t("reasons_for_rejection.#{i18n_key}.title")] = nil
      else
        top_level_reason = ::ReasonsForRejectionCountQuery::SUBREASONS_TO_TOP_LEVEL_REASONS[@search_attribute]
        i18n_key = ReasonsForRejection::TOP_LEVEL_REASONS_TO_I18N_KEYS[top_level_reason].to_s
        breadcrumb_items[t("reasons_for_rejection.#{i18n_key}.title")] = support_interface_reasons_for_rejection_application_choices_path(
          "structured_rejection_reasons[#{top_level_reason}]" => 'Yes',
        )
        breadcrumb_items[t("reasons_for_rejection.#{i18n_key}.#{@search_value}")] = nil
      end

      breadcrumb_items
    end

  private

    def top_level_reason?
      @search_attribute =~ /_y_n$/ && @search_value == 'Yes'
    end
  end
end
