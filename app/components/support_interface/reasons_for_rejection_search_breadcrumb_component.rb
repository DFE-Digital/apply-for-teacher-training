module SupportInterface
  class ReasonsForRejectionSearchBreadcrumbComponent < ViewComponent::Base
    include ViewHelper

    def initialize(search_attribute:, search_value:, recruitment_cycle_year: RecruitmentCycle.current_year)
      @search_attribute = search_attribute
      @search_value = search_value
      @recruitment_cycle_year = recruitment_cycle_year
    end

    def breadcrumb_items
      breadcrumb_items = {
        Performance: support_interface_performance_path,
        'Reasons for rejection': support_interface_reasons_for_rejection_dashboard_path(year: @recruitment_cycle_year),
      }

      unless top_level_reason?
        breadcrumb_items[@search_attribute] = support_interface_reasons_for_rejection_application_choices_path(
          'structured_rejection_reasons[id]' => @search_attribute,
          'recruitment_cycle_year' => @recruitment_cycle_year,
        )
      end

      breadcrumb_items[@search_value] = nil
      breadcrumb_items
    end

  private

    def top_level_reason?
      @search_attribute == 'id'
    end
  end
end
