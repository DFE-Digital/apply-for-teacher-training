module ProviderInterface
  class ReportTableComponent < ApplicationComponent
    include ViewHelper

    attr_reader :headers, :rows, :show_footer, :exclude_from_footer, :bold_row_headers

    def initialize(headers: [], rows: [], show_footer: true, exclude_from_footer: [], bold_row_headers: true)
      @headers = headers
      @rows = rows
      @show_footer = show_footer
      @exclude_from_footer = exclude_from_footer
      @bold_row_headers = bold_row_headers
    end

    def footer
      return [] unless show_footer && rows.any?

      num_columns = rows.first[:values].length
      @footer = Array.new(num_columns) { 0 }
      rows.each do |row|
        row[:values].each_with_index do |value, index|
          next if excluded_column_index.include?(index)

          @footer[index] += value
        end
      end

      @footer.map.with_index { |value, index| excluded_column_index.include?(index) ? '-' : value }
    end

    def excluded_column_index
      exclude_from_footer.map { |header| headers[1..].index(header) }.compact
    end
  end
end
