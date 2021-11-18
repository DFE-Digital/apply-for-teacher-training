module CandidateInterface
  class MonthlyStatisticsTableComponent < ViewComponent::Base
    attr_reader :caption, :statistics

    def initialize(caption:, statistics:)
      @caption = caption
      @statistics = statistics
    end

    def rows
      statistics['rows']
    end

    def column_names
      statistics['rows'].first.keys
    end

    def totals
      statistics['column_totals']
    end

    def name_for(row)
      _k, v = row.first
      v
    end

    def sort_value(value)
      if value == '0 to 4'
        '0'
      else
        value
      end
    end

    def data_from(row)
      k, _v = row.first
      row.delete(k)
      row
    end
  end
end
