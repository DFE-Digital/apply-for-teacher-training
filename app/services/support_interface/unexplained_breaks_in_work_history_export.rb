module SupportInterface
  class UnexplainedBreaksInWorkHistoryExport
    class UnexplainedBreak
      def initialize(month_range:)
        @month_range = month_range
      end

      def start_date
        @month_range.first.prev_month.in_time_zone
      end

      def end_date
        @month_range.last.next_month.in_time_zone
      end

      def length
        ((end_date.year * 12) + end_date.month) - ((start_date.year * 12) + start_date.month)
      end
    end

    def data_for_export
      applications = ApplicationForm
                         .where.not(date_of_birth: nil)
                         .select(:id, :candidate_id, :submitted_at, :date_of_birth, :work_history_completed)
                         .includes(:application_qualifications, :application_work_experiences, :application_work_history_breaks, :application_choices)
                         .includes(:application_qualifications, :application_work_experiences, :application_volunteering_experiences, :application_work_history_breaks, :application_choices)
                         .order(submitted_at: :desc).uniq(&:candidate_id)

      data_for_export = applications.map do |application_form|
        volunteering_experiences = application_form.application_volunteering_experiences.sort_by(&:start_date)
        explained_breaks = application_form.application_work_history_breaks.sort_by(&:start_date)
        unexplained_breaks = get_unexplained_breaks(application_form)

        next if unexplained_breaks.nil? && explained_breaks.nil?

        output = {
          'Candidate id' => application_form.candidate_id,
          'Application id' => application_form.id,
          'Application submitted' => application_form.submitted_at,
          'Course choice statuses' => application_form.application_choices.map(&:status).sort,

          'Start of working life' => start_of_working_life(application_form),
          'Total time in employment (months)' => total_time_in_employment(application_form),

        }

        if explained_breaks.any?
          output.merge!({
            'Total time of explained breaks (months)' => total_time_of_explained_breaks(explained_breaks),
            'Total time volunteering during explained breaks (months)' => total_time_volunteering_during_breaks(explained_breaks, volunteering_experiences),
            'Number of explained breaks' => explained_breaks.length,
            'Number of explained breaks in last 5 years' => breaks_in_last_five_years(explained_breaks, application_form),
            'Number of explained breaks that coincide with a volunteering experience' => breaks_that_coincide_with_volunteering_experiences(explained_breaks, volunteering_experiences),
            'Number of explained breaks that were over 50% volunteering' => breaks_with_over_fifty_percent_volunteering(explained_breaks, volunteering_experiences),
          })
        end

        if unexplained_breaks.any?
          output.merge!({
            'Total time of unexplained breaks (months)' => total_time_of_unexplained_breaks(unexplained_breaks),
            'Total time volunteering during unexplained breaks (months)' => total_time_volunteering_during_breaks(unexplained_breaks, volunteering_experiences),
            'Number of unexplained breaks' => unexplained_breaks.length,
            'Number of unexplained breaks in last 5 years' => breaks_in_last_five_years(unexplained_breaks, application_form),
            'Number of unexplained breaks that coincide with studying for a degree' => unexplained_breaks_that_coincide_with_degrees(application_form, unexplained_breaks),
            'Number of unexplained breaks that coincide with a volunteering experience' => breaks_that_coincide_with_volunteering_experiences(unexplained_breaks, volunteering_experiences),
            'Number of unexplained breaks that were over 50% volunteering' => breaks_with_over_fifty_percent_volunteering(unexplained_breaks, volunteering_experiences),
          })
        end

        output
      end

      # The DataExport class creates the header row for us so we need to ensure
      # we sort by longest hash length to ensure all headers appear
      data_for_export.compact.sort_by(&:length).reverse
    end

  private

    def start_of_working_life(application_form)
      application_form.date_of_birth.beginning_of_month + 18.years
    end

    def total_time_in_employment(application_form)
      time_in_seconds = application_form.application_work_experiences.map { |experience| experience.end_date - experience.start_date }
      convert_seconds_to_months(time_in_seconds.sum)
    end

    def total_time_of_explained_breaks(explained_breaks)
      time_in_seconds = explained_breaks.map { |work_history_break| work_history_break.end_date - work_history_break.start_date }
      convert_seconds_to_months(time_in_seconds.sum)
    end

    def total_time_of_unexplained_breaks(unexplained_breaks)
      unexplained_breaks.sum(&:length)
    end

    def total_time_volunteering_during_breaks(breaks, volunteering_experiences)
      total_time = 0
      breaks.each do |b|
        volunteering_experiences_during_break(b, volunteering_experiences).each do |v|
          total_time += volunteering_time_during_break(b, v)
        end
      end
      convert_seconds_to_months(total_time)
    end

    def volunteering_time_during_break(work_break, volunteering_experience)
      volunteering_end_date = volunteering_experience.end_date ||= Time.zone.now

      start_date = work_break.start_date < volunteering_experience.start_date ? volunteering_experience.start_date : work_break.start_date
      end_date = work_break.end_date > volunteering_end_date ? volunteering_end_date : work_break.end_date
      end_date - start_date
    end

    def breaks_in_last_five_years(breaks, application_form)
      breaks.count { |b| b.start_date > (submitted_at(application_form) - 5.years).to_date }
    end

    def unexplained_breaks_that_coincide_with_degrees(application_form, unexplained_breaks)
      degrees = application_form.application_qualifications.degrees
      unexplained_breaks.count { |unexplained_break| unexplained_break_coincides_with_a_degree(unexplained_break, degrees) }
    end

    def unexplained_break_coincides_with_a_degree(unexplained_break, degrees)
      degrees.select { |degree|
        coincides?(Date.new(degree.start_year.to_i, 1, 1), Date.new(degree.award_year.to_i, 12, 31), unexplained_break.start_date, unexplained_break.end_date)
      }.any?
    end

    def breaks_that_coincide_with_volunteering_experiences(breaks, volunteering_experiences)
      breaks.count { |b| volunteering_experiences_during_break(b, volunteering_experiences).any? }
    end

    def volunteering_experiences_during_break(work_break, volunteering_experiences)
      volunteering_experiences.select do |volunteering_experience|
        volunteering_end_date = volunteering_experience.end_date ||= Time.zone.now
        coincides?(volunteering_experience.start_date, volunteering_end_date, work_break.start_date, work_break.end_date)
      end
    end

    def coincides?(event_1_start_date, event_1_end_date, event_2_start_date, event_2_end_date)
      event_1_start_date < event_2_end_date && event_2_start_date < event_1_end_date
    end

    def breaks_with_over_fifty_percent_volunteering(breaks, volunteering_experiences)
      breaks.count { |b| volunteering_percentage_in_break(b, volunteering_experiences) > 0.5 }
    end

    def volunteering_percentage_in_break(work_break, volunteering_experiences)
      break_length = work_break.end_date - work_break.start_date
      volunteering_experiences_during_break = volunteering_experiences_during_break(work_break, volunteering_experiences)
      volunteering_during_break = 0
      volunteering_experiences_during_break.each do |v|
        volunteering_during_break += volunteering_time_during_break(work_break, v)
      end
      volunteering_during_break / break_length
    end

    def get_unexplained_breaks(application_form)
      work_history = application_form.application_work_experiences.sort_by(&:start_date)
      existing_breaks = application_form.application_work_history_breaks.sort_by(&:start_date)

      work_history_with_breaks = []
      work_history.each { |job| work_history_with_breaks << job }
      existing_breaks.each { |existing_break| work_history_with_breaks << existing_break }

      if work_history.any?
        timeline_in_months = month_range(
          start_date: start_of_working_life(application_form),
          end_date: submitted_at(application_form) - 1.month,
        )
        break_months_in_timeline = remove_months(timeline: timeline_in_months, entries: work_history, application_form: application_form)
        remaining_months = remove_months(timeline: break_months_in_timeline, entries: existing_breaks, application_form: application_form)

        create_unexplained_breaks(remaining_months)
      end
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

    def convert_seconds_to_months(time_in_seconds)
      (time_in_seconds / ActiveSupport::Duration::SECONDS_PER_MONTH).round
    end
  end
end
