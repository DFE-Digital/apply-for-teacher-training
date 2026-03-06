module RecruitmentPerformanceReport
  class DisabilityComponent < EdiReportComponent
    def title
      'Disability'
    end

    def serialized_statistics
      statistics = report&.statistics

      statistics&.each do |data|
        hesa_disability = disability_category(data['nonprovider_filter'])
        if hesa_disability
          data['subcategory'] = hesa_disability
        end
      end

      statistics&.sort_by! { |data| data['subcategory'] || data['nonprovider_filter'] }
    end

    def report
      @report ||= edi_reports.find do |edi_report|
        edi_report.category == 'disability'
      end
    end

    def disability_category(non_provider_filter)
      Hesa::Disability.find_by_code(
        non_provider_filter,
        report.recruitment_cycle_year,
      )&.value || non_provider_filter
    end
  end
end
