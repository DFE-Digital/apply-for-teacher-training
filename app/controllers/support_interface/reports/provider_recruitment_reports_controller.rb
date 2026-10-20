module SupportInterface
  module Reports
    class ProviderRecruitmentReportsController < SupportInterface::ProviderRecruitmentReportsController
      def show
        super
        @comparison_link = new_support_interface_reports_providers_regional_report_filter_path(
          provider_id: @provider.id,
          region: @region,
          recruitment_cycle_year: @recruitment_cycle_year,
        )
        @provider_recruitment_component = ProviderRecruitmentReportsComponent.new(
          statistics: @statistics,
          provider_data: @provider_data,
          provider_report: @provider_report,
          provider_edi_reports: @provider_edi_reports,
          report_type: @report_type,
          provider: @provider,
          region: @region,
          comparison_link: @comparison_link,
          reports_ready: reports_ready?,
        )
      end
    end
  end
end
