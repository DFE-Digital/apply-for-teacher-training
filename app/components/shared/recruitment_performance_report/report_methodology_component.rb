module RecruitmentPerformanceReport
  class ReportMethodologyComponent < ViewComponent::Base
    def initialize(
      provider_report:,
      current_timetable:,
      interface:,
      region: Publications::RegionalRecruitmentPerformanceReport.all_of_england_key
    )
      @provider_report = provider_report
      @current_timetable = current_timetable
      @interface = interface
      @region = region
    end

    def comparison_link
      if @interface == 'support'
        new_support_interface_regional_report_filter_path(region: @region)
      else
        new_provider_interface_reports_provider_regional_report_filter_path
      end
    end
  end
end
