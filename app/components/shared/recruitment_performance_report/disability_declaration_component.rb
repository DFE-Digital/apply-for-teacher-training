module RecruitmentPerformanceReport
  class DisabilityDeclarationComponent < EdiReportComponent
    def title
      'Disability declaration'
    end

    def serialized_statistics
      statistics = report&.statistics

      statistics&.each do |data|
        label = label_map[data['nonprovider_filter']]
        if label
          data['subcategory'] = label
        end
      end

      statistics&.sort_by! { |data| data['subcategory'] || data['nonprovider_filter'] }
    end

    def report
      @report ||= edi_reports.find do |edi_report|
        edi_report.category == 'disability_declaration'
      end
    end

  private

    def label_map
      {
        'Disability declared' => 'At least one disability or health condition declared',
        'No disability declared' => 'I do not have any of these disabilities or health conditions',
      }
    end
  end
end
