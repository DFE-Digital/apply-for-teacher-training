module SupportInterface
  class UnexplainedBreaksInWorkHistoryExport
    class UnexplainedBreak
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
        ((end_date.year * 12) + end_date.month) - ((start_date.year * 12) + start_date.month)
      end
    end

    def data_for_export
      data_for_export = Candidate.all.map do |candidate|
        application_form = candidate.application_forms.order(:submitted_at).last
        next if application_form.nil?

        unexplained_breaks = get_unexplained_breaks(application_form)
        next if unexplained_breaks.nil?

        total_unexplained_time = unexplained_breaks.sum(&:length)
        output = {
            'Candidate id' => application_form.candidate_id,
            'Application id' => application_form.id,
            'Start of working life' => get_start_of_working_life(application_form),
            'Number of unexplained breaks' => unexplained_breaks.length,
            'Total unexplained time (months)' => total_unexplained_time
        }
        output
      end

      data_for_export.compact
    end

    private

    def get_unexplained_breaks(application_form)
      work_history = application_form.application_work_experiences.sort_by(&:start_date)
      existing_breaks = application_form.application_work_history_breaks.sort_by(&:start_date)

      work_history_with_breaks = []
      work_history.each { |job| work_history_with_breaks << job }
      existing_breaks.each { |existing_break| work_history_with_breaks << existing_break }

      if work_history.any?
        timeline_in_months = month_range(
            start_date: get_start_of_working_life(application_form),
            end_date: submitted_at(application_form) - 1.month,
        )
        break_months_in_timeline = remove_months(timeline: timeline_in_months, entries: work_history, application_form: application_form)
        remaining_months = remove_months(timeline: break_months_in_timeline, entries: existing_breaks, application_form: application_form)

        create_unexplained_breaks(remaining_months)
      end
    end

    def get_start_of_working_life(application_form)
      application_form.date_of_birth.beginning_of_month + 18.years
    end

    def submitted_at(application_form)
      application_form.submitted_at || Time.zone.now
    end

    def month_range(start_date:, end_date:)
      (start_date.to_date..end_date.to_date).map(&:beginning_of_month).uniq
    end

    def remove_months(timeline:, entries:, application_form:)
      remaining_months_in_timeline = timeline

      entries.each do |entry|
        entry_end_date = entry.end_date.nil? ? submitted_at(application_form) : entry.end_date
        months_in_entry_period = month_range(start_date: entry.start_date, end_date: entry_end_date)

        remaining_months_in_timeline -= months_in_entry_period
      end

      remaining_months_in_timeline
    end

    def create_unexplained_breaks(break_months_in_timeline)
      return [] if break_months_in_timeline.empty?

      breaks = []
      current_break = [break_months_in_timeline.first]

      break_months_in_timeline.drop(1).each do |month|
        if current_break.last.next_month == month
          current_break << month
        else
          breaks << UnexplainedBreak.new(month_range: current_break)
          current_break = [month]
        end
      end

      breaks << UnexplainedBreak.new(month_range: current_break)
    end
  end
end
