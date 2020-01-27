class GetBreaksInWorkHistory
  class << self
    def call(application_form)
      breaks = {}

      @works = application_form.application_work_experiences.order(:start_date)

      @works.each do |work|
        months = next_work_breaks_in_months(work)
        breaks[work.id] = months unless months.zero?
      end

      breaks
    end

  private

    def next_work_breaks_in_months(work)
      return 0 unless work.end_date

      next_work = @works.find_by(['start_date > ?', work.start_date])
      next_work_start_date = next_work ? next_work.start_date : Time.zone.today

      gap_in_months(work.end_date, next_work_start_date)
    end

    def gap_in_months(start_date, end_date)
      month_gap = (end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month) - 1
      [month_gap, 0].max
    end
  end
end
