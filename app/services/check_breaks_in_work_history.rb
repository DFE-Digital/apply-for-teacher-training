class CheckBreaksInWorkHistory
  class << self
    def call(application_form)
      jobs = application_form.application_work_experiences.sort_by(&:start_date)

      previous_end_date = nil
      jobs.each do |job|
        return true if month_or_more_break_between_dates?(previous_end_date, job.start_date)

        return false if less_than_month_to_current_date?(job.end_date)

        previous_end_date = [previous_end_date, job.end_date].compact.max
      end
      month_or_more_break_between_end_date_and_current_date?(previous_end_date)
    end

  private

    def current_role?(job)
      job.end_date.nil?
    end

    def month_or_more_break_between_end_date_and_current_date?(end_date)
      month_or_more_break_between_dates?(end_date, Time.zone.now)
    end

    def month_or_more_break_between_dates?(end_date, next_date)
      end_date.present? && end_date.next_month <= next_date
    end

    def less_than_month_to_current_date?(end_date)
      end_date.nil? || end_date.next_month > Time.zone.now
    end
  end
end
