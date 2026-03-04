module RecruitmentPerformanceReport
  class DisabilityComponent < EdiReportComponent
    def report
      @report ||= edi_reports.find do |edi_report|
        edi_report.category == 'disability'
      end
    end

    def disability_category(non_provider_filter)
      Hesa::Disability.find_by_code(non_provider_filter, recruitment_cycle_year)&.value || non_provider_filter
    end
  end
end
