module RecruitmentPerformanceReport
  class AboutThisDataSectionComponent < ViewComponent::Base
    def initialize(provider_report)
      @provider_report = provider_report
    end
  end
end
