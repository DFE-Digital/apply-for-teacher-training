module Publications
  class MidCycleReportController < ApplicationController
    def show
      @national_data = Publications::NationalMidCycleReport.last&.statistics
    end
  end
end
