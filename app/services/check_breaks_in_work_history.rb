class CheckBreaksInWorkHistory
  class << self
    def call(application_form)
      jobs = application_form.application_work_experiences.sort_by(&:start_date)

      latest_end_date = nil
      jobs.each do |job|
        return true if month_or_more_break_between_dates?(latest_end_date, job.start_date)

        return false unless month_or_more_break_between_dates?(job.end_date, submitted_at(application_form))

        latest_end_date = [latest_end_date, job.end_date].compact.max
      end
      month_or_more_break_between_dates?(latest_end_date, submitted_at(application_form))
    end

  private

    def month_or_more_break_between_dates?(end_date, next_date)
      end_date.present? && end_date.next_month <= next_date
    end

    def submitted_at(application_form)
      application_form.submitted_at || Time.zone.now
    end
  end
end
