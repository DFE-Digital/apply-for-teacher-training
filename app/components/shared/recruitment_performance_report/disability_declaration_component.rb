module RecruitmentPerformanceReport
  class DisabilityDeclarationComponent < EdiReportComponent
    def title
      'Disability declaration'
    end

    def report
      @report ||= edi_reports.find do |edi_report|
        edi_report.category == 'disability_declaration'
      end
    end
  end
end
