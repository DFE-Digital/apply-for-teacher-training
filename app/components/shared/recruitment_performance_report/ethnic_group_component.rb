module RecruitmentPerformanceReport
  class EthnicGroupComponent < EdiReportComponent
    def title
      'Ethnic group'
    end

    def report
      @report ||= edi_reports.find do |edi_report|
        edi_report.category == 'ethnic_group'
      end
    end
  end
end
