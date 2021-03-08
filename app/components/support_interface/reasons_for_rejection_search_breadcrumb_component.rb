module SupportInterface
  class ReasonsForRejectionSearchBreadcrumbComponent < ViewComponent::Base
    include ViewHelper

    def initialize(search_attribute:, search_value:)
      @search_attribute = search_attribute
      @search_value = search_value
    end

    def items
      items = [
        {
          text: 'Performance',
          path: support_interface_performance_path,
        },
        {
          text: 'Structured reasons for rejection',
          path: support_interface_reasons_for_rejection_dashboard_path,
        },
      ]
      if top_level_reason?
        i18n_key = ReasonsForRejection::TOP_LEVEL_REASONS_TO_I18N_KEYS[@search_attribute].to_s
        items << {
          text: t("reasons_for_rejection.#{i18n_key}.title"),
        }
      else
        top_level_reason = ::ReasonsForRejectionCountQuery::SUBREASONS_TO_TOP_LEVEL_REASONS[@search_attribute]
        i18n_key = ReasonsForRejection::TOP_LEVEL_REASONS_TO_I18N_KEYS[top_level_reason].to_s
        items << {
          text: t("reasons_for_rejection.#{i18n_key}.title"),
          path: support_interface_reasons_for_rejection_application_choices_path(
            "structured_rejection_reasons[#{top_level_reason}]" => 'Yes',
          ),
        }
        items << {
          text: t("reasons_for_rejection.#{i18n_key}.#{@search_value}"),
        }
      end

      items
    end

  private

    def top_level_reason?
      @search_attribute =~ /_y_n$/ && @search_value == 'Yes'
    end
  end
end
