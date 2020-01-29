class GetBreaksInMonths
  class << self
    def call(start_date, end_date)
      return 0 unless start_date

      end_date ||= Time.zone.now

      month_break = (end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month) - 1
      [month_break, 0].max
    end
  end
end
