module Publications
  class RecruitmentCyclePerformanceReportsController < ApplicationController
    before_action :redirect_if_feature_inactive

    def show
      @national_data = national_recruitment_cycle_performance_report&.statistics
      @publication_date = national_recruitment_cycle_performance_report&.publication_date
    end

  private

    def national_recruitment_cycle_performance_report
      @national_recruitment_cycle_performance_report ||= Publications::NationalRecruitmentCyclePerformanceReport.last
    end

    def redirect_if_feature_inactive
      if FeatureFlag.inactive? :recruitment_performance_report
        redirect_to publications_mid_cycle_report_path
      end
    end
  end
end
