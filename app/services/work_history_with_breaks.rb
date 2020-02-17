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

  def initialize(application_form)
    @work_history = application_form.application_work_experiences.sort_by(&:start_date)
    @existing_breaks = application_form.application_work_history_breaks.sort_by(&:start_date)
    @current_job = nil
  end

  def timeline
    work_history_with_breaks = []

    @work_history.each { |job| work_history_with_breaks << job }
    @existing_breaks.each { |existing_break| work_history_with_breaks << existing_break }

    if @work_history.any?
      timeline_in_months = month_range(
        start_date: Time.zone.now - 5.years,
        end_date: Time.zone.now - 1.month,
      )
      break_months_in_timeline = remove_working_months(timeline_in_months)
      breaks = break_entries(break_months_in_timeline)
      work_history_with_breaks += breaks if breaks.any?
    end

    work_history_with_breaks.sort_by(&:start_date)
  end

private

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
        unless existing_break_covers_break_period?(current_break)
          breaks << BreakPlaceholder.new(month_range: current_break)
        end

        current_break = [month]
      end
    end

    unless existing_break_covers_break_period?(current_break)
      breaks << BreakPlaceholder.new(month_range: current_break)
    end

    breaks
  end

  def existing_break_covers_break_period?(current_break)
    existing_break_covering_break_period = @existing_breaks.select do |existing_break|
      break_placeholder = BreakPlaceholder.new(month_range: current_break)

      same_start_date = existing_break.start_date.to_date == break_placeholder.start_date
      same_end_date = existing_break.end_date.to_date == break_placeholder.end_date

      same_start_date && same_end_date
    end

    existing_break_covering_break_period.any?
  end
end
