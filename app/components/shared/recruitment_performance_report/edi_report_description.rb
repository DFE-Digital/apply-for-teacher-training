module RecruitmentPerformanceReport
  class EdiReportDescription < ApplicationComponent
    attr_reader :provider_report

    def initialize(provider_report:)
      @provider_report = provider_report
    end
  end
end
