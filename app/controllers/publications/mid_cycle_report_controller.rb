module Publications
  class MidCycleReportController < ApplicationController
    def show
      @national_data = Publications::NationalMidCycleReport.last&.statistics
      @publication_date = Publications::NationalMidCycleReport.last&.publication_date
    end
  end
end
