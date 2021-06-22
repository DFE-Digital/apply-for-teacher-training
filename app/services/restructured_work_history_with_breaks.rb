class RestructuredWorkHistoryWithBreaks
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
    @application_form = application_form
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
        start_date: work_history_with_breaks.first.start_date,
        end_date: submitted_at - 1.month,
      )
      break_months_in_timeline = remove_months(timeline: timeline_in_months, entries: @work_history)
      remaining_months = remove_months(timeline: break_months_in_timeline, entries: @existing_breaks)
      break_placeholders = break_placeholder_entries(remaining_months)
      work_history_with_breaks += break_placeholders if break_placeholders.any?
    end

    work_history_with_breaks.sort_by(&:start_date)
  end

private

  def submitted_at
    @application_form.submitted_at || Time.zone.now
  end

  def month_range(start_date:, end_date:)
    (start_date.to_date..end_date.to_date).map(&:beginning_of_month).uniq
  end

  def remove_months(timeline:, entries:)
    remaining_months_in_timeline = timeline

    entries.each do |entry|
      entry_end_date = if entries.last == entry && entry.is_a?(ApplicationWorkExperience) && entry.end_date.nil?
                         Time.zone.now
                       else
                         entry.end_date.nil? ? submitted_at : entry.end_date
                       end

      months_in_entry_period = month_range(start_date: entry.start_date, end_date: entry_end_date)

      remaining_months_in_timeline -= months_in_entry_period
    end

    remaining_months_in_timeline
  end

  def break_placeholder_entries(break_months_in_timeline)
    return [] if break_months_in_timeline.empty?

    breaks = []
    current_break = [break_months_in_timeline.first]

    break_months_in_timeline.drop(1).each do |month|
      if current_break.last.next_month == month
        current_break << month
      else
        breaks << BreakPlaceholder.new(month_range: current_break)
        current_break = [month]
      end
    end

    breaks << BreakPlaceholder.new(month_range: current_break)
  end
end
