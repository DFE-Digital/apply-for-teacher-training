class ProviderRecruitmentReportsComponent < ApplicationComponent
  attr_reader :statistics, :provider_data, :provider_report, :provider_edi_reports,
              :report_type, :provider, :region, :comparison_link, :reports_ready

  def initialize(
    statistics:,
    provider_data:,
    provider_report:,
    provider_edi_reports:,
    report_type:,
    provider:,
    region:,
    comparison_link:,
    reports_ready:
  )
    @statistics = statistics
    @provider_data = provider_data
    @provider_report = provider_report
    @provider_edi_reports = provider_edi_reports
    @report_type = report_type
    @provider = provider
    @region = region
    @comparison_link = comparison_link
    @reports_ready = reports_ready
  end

  def render?
    reports_ready
  end
end
