module SupportInterface
  class WorkHistoryBreakExport
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

    def data_for_export(*)
      data_for_export = application_forms.map do |application_form|
        volunteering_experiences = application_form.application_volunteering_experiences.sort_by(&:start_date)
        explained_breaks = application_form.application_work_history_breaks.sort_by(&:start_date)
        unexplained_breaks = get_unexplained_breaks(application_form)

        next if unexplained_breaks.nil? && explained_breaks.nil?

        output = {
          candidate_id: application_form.candidate_id,
          application_form_id: application_form.id,
          submitted_at: submitted_at(application_form).iso8601,
          course_choice_statuses: application_form.application_choices.map(&:status).sort,
          start_of_working_life: start_of_working_life(application_form),
          total_time_in_employment: total_time_in_employment(application_form),
        }

        output.merge!(explained_breaks_columns(application_form, explained_breaks, volunteering_experiences)) if explained_breaks.present?
        output.merge!(unexplained_breaks_columns(application_form, unexplained_breaks, volunteering_experiences)) if unexplained_breaks.present?

        output
      end

      # The DataExport class creates the header row for us so we need to ensure
      # we sort by longest hash length to ensure all headers appear
      data_for_export.compact.sort_by(&:length).reverse
    end

  private

    def application_forms
      ApplicationForm
         .where.not(date_of_birth: nil)
         .select(:id, :candidate_id, :submitted_at, :date_of_birth, :work_history_completed)
         .includes(:application_qualifications, :application_work_experiences, :application_work_history_breaks, :application_volunteering_experiences, :application_choices)
         .order(submitted_at: :desc).uniq(&:candidate_id)
    end

    def explained_breaks_columns(application_form, explained_breaks, volunteering_experiences)
      {
        total_time_of_explained_breaks: total_time_of_explained_breaks(explained_breaks),
        total_time_volunteering_during_explained_breaks: total_time_volunteering_during_breaks(explained_breaks, volunteering_experiences, application_form),
        number_of_explained_breaks: explained_breaks.length,
        number_of_explained_breaks_in_last_five_years: breaks_in_last_five_years(explained_breaks, application_form),
        number_of_explained_breaks_that_coincide_with_a_volunteering_experience: breaks_that_coincide_with_volunteering_experiences(explained_breaks, volunteering_experiences, application_form),
        number_of_explained_breaks_that_were_over_fifty_percent_volunteering: breaks_with_over_fifty_percent_volunteering(explained_breaks, volunteering_experiences, application_form),
      }
    end

    def unexplained_breaks_columns(application_form, unexplained_breaks, volunteering_experiences)
      {
        total_time_of_unexplained_breaks: total_time_of_unexplained_breaks(unexplained_breaks),
        total_time_volunteering_during_unexplained_breaks: total_time_volunteering_during_breaks(unexplained_breaks, volunteering_experiences, application_form),
        number_of_unexplained_breaks: unexplained_breaks.length,
        number_of_unexplained_breaks_in_last_five_years: breaks_in_last_five_years(unexplained_breaks, application_form),
        number_of_unexplained_breaks_that_coincide_with_studying_for_a_degree: unexplained_breaks_that_coincide_with_degrees(application_form, unexplained_breaks),
        number_of_unexplained_breaks_that_coincide_with_a_volunteering_experience: breaks_that_coincide_with_volunteering_experiences(unexplained_breaks, volunteering_experiences, application_form),
        number_of_unexplained_breaks_that_were_over_fifty_percent_volunteering: breaks_with_over_fifty_percent_volunteering(unexplained_breaks, volunteering_experiences, application_form),
      }
    end

    def start_of_working_life(application_form)
      date = application_form.date_of_birth.beginning_of_month + 18.years
      date.to_time.iso8601
    end

    def total_time_in_employment(application_form)
      time_in_seconds = application_form.application_work_experiences.map do |experience|
        end_date = experience_end_date(experience, application_form)
        end_date - experience.start_date
      end
      convert_seconds_to_months(time_in_seconds.sum)
    end

    def total_time_of_explained_breaks(explained_breaks)
      time_in_seconds = explained_breaks.map { |work_history_break| work_history_break.end_date - work_history_break.start_date }
      convert_seconds_to_months(time_in_seconds.sum)
    end

    def total_time_of_unexplained_breaks(unexplained_breaks)
      unexplained_breaks.sum(&:length)
    end

    def total_time_volunteering_during_breaks(breaks, volunteering_experiences, application_form)
      total_time = breaks.map.sum do |work_break|
        volunteering_experiences_during_break(work_break, volunteering_experiences, application_form).inject(0) do |_time, volunteering_experience|
          volunteering_time_during_break(work_break, volunteering_experience, application_form)
        end
      end
      convert_seconds_to_months(total_time)
    end

    def volunteering_time_during_break(work_break, volunteering_experience, application_form)
      volunteering_end_date = experience_end_date(volunteering_experience, application_form)

      start_date = work_break.start_date < volunteering_experience.start_date ? volunteering_experience.start_date : work_break.start_date
      end_date = work_break.end_date > volunteering_end_date ? volunteering_end_date : work_break.end_date
      end_date - start_date
    end

    def breaks_in_last_five_years(breaks, application_form)
      breaks.count { |work_break| work_break.start_date > (submitted_at(application_form) - 5.years).to_date }
    end

    def unexplained_breaks_that_coincide_with_degrees(application_form, unexplained_breaks)
      degrees = application_form.application_qualifications.degrees
      unexplained_breaks.count { |unexplained_break| unexplained_break_coincides_with_a_degree(unexplained_break, degrees) }
    end

    def unexplained_break_coincides_with_a_degree(unexplained_break, degrees)
      degrees.select do |degree|
        coincides?(Date.new(degree.start_year.to_i, 1, 1), Date.new(degree.award_year.to_i, 12, 31), unexplained_break.start_date, unexplained_break.end_date)
      end.any?
    end

    def breaks_that_coincide_with_volunteering_experiences(breaks, volunteering_experiences, application_form)
      breaks.count { |work_break| volunteering_experiences_during_break(work_break, volunteering_experiences, application_form).any? }
    end

    def volunteering_experiences_during_break(work_break, volunteering_experiences, application_form)
      volunteering_experiences.select do |volunteering_experience|
        volunteering_end_date = experience_end_date(volunteering_experience, application_form)
        coincides?(volunteering_experience.start_date, volunteering_end_date, work_break.start_date, work_break.end_date)
      end
    end

    def coincides?(event_1_start_date, event_1_end_date, event_2_start_date, event_2_end_date)
      event_1_start_date < event_2_end_date && event_2_start_date < event_1_end_date
    end

    def breaks_with_over_fifty_percent_volunteering(breaks, volunteering_experiences, application_form)
      breaks.count { |work_break| volunteering_percentage_in_break(work_break, volunteering_experiences, application_form) > 0.5 }
    end

    def volunteering_percentage_in_break(work_break, volunteering_experiences, application_form)
      break_length = work_break.end_date - work_break.start_date
      volunteering_experiences_during_break = volunteering_experiences_during_break(work_break, volunteering_experiences, application_form)
      volunteering_during_break = 0
      volunteering_experiences_during_break.each do |volunteering_experience|
        volunteering_during_break += volunteering_time_during_break(work_break, volunteering_experience, application_form)
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
        break_months_in_timeline = remove_months(timeline: timeline_in_months, entries: work_history, application_form:)
        remaining_months = remove_months(timeline: break_months_in_timeline, entries: existing_breaks, application_form:)

        create_unexplained_breaks(remaining_months)
      end
    end

    def experience_end_date(experience, application_form)
      experience.end_date ||= submitted_at(application_form)
    end

    def submitted_at(application_form)
      application_form.submitted_at || Time.zone.now
    end

    def month_range(start_date:, end_date:)
      (start_date.to_date..end_date.to_date).map(&:beginning_of_month).uniq
    end

    def remove_months(timeline:, entries:, application_form:)
      months_in_entry_periods = entries.flat_map do |entry|
        entry_end_date = entry.end_date.nil? ? submitted_at(application_form) : entry.end_date
        month_range(start_date: entry.start_date, end_date: entry_end_date)
      end
      timeline - months_in_entry_periods
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
