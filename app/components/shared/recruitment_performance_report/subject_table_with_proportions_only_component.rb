module RecruitmentPerformanceReport
  class SubjectTableWithProportionsOnlyComponent < SubjectTableComponent
    attr_reader :provider, :table_caption, :summary_row, :subject_rows

    def format_number(row, column_name)
      number = row.send(column_name)

      # We want nil to read 'Not available'
      return t('shared.not_available') if number.nil?

      number_to_percentage(number * 100, precision: 0)
    end

    def columns
      %i[last_cycle this_cycle national_last_cycle national_this_cycle]
    end
  end
end
