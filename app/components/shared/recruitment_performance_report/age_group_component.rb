module RecruitmentPerformanceReport
  class AgeGroupComponent < EdiReportComponent
    def title
      'Age group'
    end

    def report
      @report ||= edi_reports.find do |edi_report|
        edi_report.category == 'age_group'
      end
    end
  end
end
