module ProviderInterface
  class ReportTableComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :headers, :rows, :show_footer, :ignore_last_footer_column

    def initialize(headers: [], rows: [], show_footer: true, ignore_last_footer_column: false)
      @headers = headers
      @rows = rows
      @show_footer = show_footer
      @ignore_last_footer_column = ignore_last_footer_column
    end

    def footer
      return [] unless show_footer && rows.any?

      @footer = Array.new(rows.first[:values].length) { 0 }
      rows.each do |row|
        row[:values].each_with_index do |value, index|
          next if ignore_last_footer_column && index == row[:values].length - 1

          @footer[index] += value
        end
      end

      @footer.map { |value| ignore_last_footer_column && value == @footer.last ? '-' : value }
    end
  end
end
