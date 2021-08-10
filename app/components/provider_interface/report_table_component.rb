module ProviderInterface
  class ReportTableComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :headers, :rows, :show_footer

    def initialize(headers: [], rows: [], show_footer: true)
      @headers = headers
      @rows = rows
      @show_footer = show_footer
    end

    def footer
      [] unless show_footer

      @footer = Array.new(rows.first[:values].length) { 0 }
      rows.each do |row|
        row[:values].each_with_index do |value, index|
          @footer[index] += value
        end
      end

      @footer
    end
  end
end
