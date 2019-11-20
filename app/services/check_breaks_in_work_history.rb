class CheckBreaksInWorkHistory
  class << self
    def call(application_form)
      jobs = application_form.application_work_experiences.sort_by(&:start_date)

      previous_end_date = nil
      jobs.each do |job|
        return true if previous_end_date && previous_end_date.next_month <= job.start_date

        return false if job.end_date.nil? || job.end_date.next_month > Time.zone.now

        previous_end_date = [previous_end_date, job.end_date].compact.max
      end
      previous_end_date.present? && previous_end_date.next_month <= Time.zone.now
    end

  private

    def break_between_job_and_current_date?(job)
      if current_role?(job)
        false
      else
        month_or_more_break_between_end_date_and_current_date?(job)
      end
    end

    def current_role?(job)
      job.end_date.nil?
    end

    def month_or_more_break_between_end_date_and_current_date?(job)
      job.end_date && job.end_date.next_month <= Time.zone.now
    end

    def month_or_more_break_between?(first_job, next_job)
      first_job.end_date && first_job.end_date.next_month <= next_job.start_date
    end
  end
end
