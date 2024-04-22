module Publications
  class RecruitmentPerformanceReportsController < ApplicationController
    def show
      @national_data = national_recruitment_performance_report&.statistics
      @publication_date = national_recruitment_performance_report&.publication_date
    end

    def national_recruitment_performance_report
      @national_recruitment_performance_report ||= Publications::NationalRecruitmentPerformanceReport.last
    end
  end
end
