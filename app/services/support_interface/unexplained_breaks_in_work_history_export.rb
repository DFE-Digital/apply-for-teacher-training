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
      applications = ApplicationForm
                         .where.not(date_of_birth: nil)
                         .select(:id, :candidate_id, :submitted_at, :date_of_birth, :work_history_completed)
                         .includes(:application_qualifications, :application_work_experiences, :application_work_history_breaks, :application_choices)
                         .includes(:application_qualifications, :application_work_experiences, :application_volunteering_experiences, :application_work_history_breaks, :application_choices)
                         .order(submitted_at: :desc).uniq(&:candidate_id)

      data_for_export = applications.map do |application_form|
        unexplained_breaks = get_unexplained_breaks(application_form)
        next if unexplained_breaks.nil?

        total_unexplained_time = unexplained_breaks.sum(&:length)

        unexplained_breaks_in_last_five_years = unexplained_breaks.count do |unexplained_break|
          unexplained_break.start_date > (submitted_at(application_form) - 5.years).to_date
        end

        degrees = application_form.application_qualifications.degrees
        unexplained_breaks_that_coincide_with_degrees = unexplained_breaks.count do |unexplained_break|
          unexplained_break_coincides_with_a_degree(unexplained_break, degrees)
        end

        volunteering_experiences = application_form.application_volunteering_experiences.sort_by(&:start_date)
        unexplained_breaks_that_coincide_with_volunteering_experiences = unexplained_breaks.count do |unexplained_break|
          unexplained_break_coincides_with_volunteering_experience(unexplained_break, volunteering_experiences)
        end

        explained_breaks_that_coincide_with_volunteering_experiences = application_form.application_work_history_breaks.count do |explained_break|
          explained_break_coincides_with_volunteering_experience(explained_break, volunteering_experiences)
        end

        explained_breaks_in_last_five_years = application_form.application_work_history_breaks.count do |explained_break|
          explained_break.start_date > (submitted_at(application_form) - 5.years).to_date
        end

        output = {
          'Candidate id' => application_form.candidate_id,
          'Application id' => application_form.id,
          'Start of working life' => get_start_of_working_life(application_form),
          'Total time in employment (months)' => total_time_in_employment(application_form),
          'Total unexplained time (months)' => total_unexplained_time,
          'Total time of explained work breaks' => total_time_of_explained_work_breaks(application_form),
          'Number of explained breaks' => application_form.application_work_history_breaks.length,
          'Number of explained breaks in last 5 years' => explained_breaks_in_last_five_years,
          'Number of unexplained breaks' => unexplained_breaks.length,
          'Number of unexplained breaks in last 5 years' => unexplained_breaks_in_last_five_years,
          'Number of unexplained breaks that coincide with studying for a degree' => unexplained_breaks_that_coincide_with_degrees,
          'Number of unexplained breaks that coincide with a volunteering experience' => unexplained_breaks_that_coincide_with_volunteering_experiences,
          'Number of explained breaks that coincide with a volunteering experience' => explained_breaks_that_coincide_with_volunteering_experiences,
          'Course choice statuses' => application_form.application_choices.map(&:status).sort,
          'Application submitted' => application_form.submitted_at,
        }
        output
      end

      data_for_export.compact
    end

  private

    def total_time_in_employment(application_form)
      time_in_seconds = application_form.application_work_experiences.map { |experience| experience.end_date - experience.start_date }
      (time_in_seconds.sum / ActiveSupport::Duration::SECONDS_PER_MONTH).round
    end

    def total_time_of_explained_work_breaks(application_form)
      time_in_seconds = explained_breaks.map { |work_history_break| work_history_break.end_date - work_history_break.start_date }
      (time_in_seconds.sum / ActiveSupport::Duration::SECONDS_PER_MONTH).round
    end

    def unexplained_break_coincides_with_a_degree(unexplained_break, degrees)
      degrees.select { |degree|
        Date.new(degree.start_year.to_i, 1, 1) < unexplained_break.end_date &&
          unexplained_break.start_date < Date.new(degree.award_year.to_i, 12, 31)
      }
          .any?
    end

    def unexplained_break_coincides_with_volunteering_experience(unexplained_break, volunteering_experiences)
      volunteering_experiences.select { |volunteering_experience|
        volunteering_end_date = volunteering_experience.end_date ||= Time.zone.now

        volunteering_experience.start_date < unexplained_break.end_date &&
            unexplained_break.start_date < volunteering_end_date
      }
          .any?
    end

    def explained_break_coincides_with_volunteering_experience(explained_break, volunteering_experiences)
      volunteering_experiences.select { |volunteering_experience|
        volunteering_end_date = volunteering_experience.end_date ||= Time.zone.now
        volunteering_experience.start_date < explained_break.end_date &&
            explained_break.start_date < volunteering_end_date
      }
          .any?
    end

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
