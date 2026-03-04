module RecruitmentPerformanceReport
  class SexComponent < EdiReportComponent
    def report
      @report ||= edi_reports.find do |edi_report|
        edi_report.category == 'sex'
      end
    end
  end
end
