module SupportInterface
  class ReasonsForRejectionSearchBreadcrumbComponent < ViewComponent::Base
    include ViewHelper

    def initialize(search_attribute:, search_value:, recruitment_cycle_year: RecruitmentCycleTimetable.current_year)
      @search_attribute = search_attribute.to_s
      @search_value = search_value.to_s
      @recruitment_cycle_year = recruitment_cycle_year
    end

    def breadcrumb_items
      breadcrumb_items = {
        Performance: support_interface_performance_path,
        'Reasons for rejection': support_interface_reasons_for_rejection_dashboard_path(year: @recruitment_cycle_year),
      }

      unless top_level_reason?
        breadcrumb_items[@search_attribute.titleize] = support_interface_reasons_for_rejection_application_choices_path(
          'structured_rejection_reasons[id]' => @search_attribute,
          'recruitment_cycle_year' => @recruitment_cycle_year,
        )
      end

      breadcrumb_items[@search_value.titleize] = nil
      breadcrumb_items
    end

  private

    def top_level_reason?
      @search_attribute == 'id'
    end
  end
end
