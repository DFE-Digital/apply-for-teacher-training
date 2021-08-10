module ProviderInterface
  class ReportTableComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def report
      render ProviderInterface::ReportTableComponent.new(headers: headers,
                                                         rows: row_data)
    end

    def report_without_footer
      render ProviderInterface::ReportTableComponent.new(headers: headers,
                                                         rows: row_data,
                                                         show_footer: false)
    end

  private

    def headers
      ['Course', 'Received', 'Interviewing', 'Offered', 'Awaiting conditions', 'Ready to enrol']
    end

    def row_data
      10.times.map do
        {
          header: "#{Faker::Educator.subject} (#{Faker::Alphanumeric.alphanumeric(number: 4, min_alpha: 1).upcase})",
          subheader: Faker::University.name,
          values: numbers_row,
        }
      end
    end

    def numbers_row
      5.times.map { Faker::Number.non_zero_digit }
    end
  end
end
