module SupportInterface
  class ProviderRecruitmentReportsComponent < ApplicationComponent
    attr_reader :statistics, :provider_data, :provider_report, :provider_edi_reports,
                :report_type, :provider, :region, :current_timetable, :recruitment_cycle_year,
                :return_to

    def initialize(
      statistics:,
      provider_data:,
      provider_report:,
      provider_edi_reports:,
      report_type:,
      provider:,
      region:,
      current_timetable:,
      recruitment_cycle_year:,
      return_to:
    )
      @statistics = statistics
      @provider_data = provider_data
      @provider_report = provider_report
      @provider_edi_reports = provider_edi_reports
      @report_type = report_type
      @provider = provider
      @region = region
      @current_timetable = current_timetable
      @recruitment_cycle_year = recruitment_cycle_year
      @return_to = return_to
    end
  end
end
