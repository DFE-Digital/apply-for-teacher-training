module RecruitmentPerformanceReport
  class EdiReportDescription < ViewComponent::Base
    attr_reader :provider_report

    def initialize(provider_report:)
      @provider_report = provider_report
    end
  end
end
