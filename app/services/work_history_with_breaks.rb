class WorkHistoryWithBreaks
  class BreakPlaceholder
    def initialize(month_range:)
      @month_range = month_range
    end

    def start_date
      @month_range.first.prev_month
    end

    def end_date
      @month_range.last.next_month
    end

    def length
      @month_range.count
    end
  end

  def initialize(work_history)
    @work_history = work_history.sort_by(&:start_date)
    @current_job = nil
  end

  def timeline
    return [] if @work_history.empty?

    work_history_with_breaks = []

    @work_history.each { |job| work_history_with_breaks << job_entry(job) }

    timeline_in_months = month_range(
      start_date: @work_history.first.start_date,
      end_date: Time.zone.now - 1.month,
    )
    break_months_in_timeline = remove_working_months(timeline_in_months)
    breaks = break_entries(break_months_in_timeline)
    work_history_with_breaks += breaks if breaks.any?

    work_history_with_breaks.sort_by! { |entry| entry[:entry].start_date }
  end

private

  def job_entry(job)
    { type: :job, entry: job }
  end

  def break_placeholder_entry(month_range)
    { type: :break_placeholder, entry: BreakPlaceholder.new(month_range: month_range) }
  end

  def month_range(start_date:, end_date:)
    (start_date.to_date..end_date.to_date).map(&:beginning_of_month).uniq
  end

  def remove_working_months(timeline_in_months)
    break_months_in_timeline = timeline_in_months

    @work_history.each do |job|
      job_end_date = job.end_date.nil? ? Time.zone.now : job.end_date
      months_in_job_period = month_range(start_date: job.start_date, end_date: job_end_date)

      break_months_in_timeline -= months_in_job_period
    end

    break_months_in_timeline
  end

  def break_entries(break_months_in_timeline)
    return [] if break_months_in_timeline.empty?

    breaks = []
    current_break = [break_months_in_timeline.first]

    break_months_in_timeline.drop(1).each do |month|
      if current_break.last.next_month == month
        current_break << month
      else
        breaks << break_placeholder_entry(current_break)
        current_break = [month]
      end
    end

    breaks << break_placeholder_entry(current_break)
  end
end
