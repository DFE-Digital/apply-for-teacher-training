class GetWorkHistoryWithBreaks
  def initialize(work_history)
    @work_history = work_history.sort_by(&:start_date).to_a.append(nil)
    @work_history_with_breaks = []
    @current_job = nil
  end

  def call
    @work_history.each_cons(2) do |first_job, second_job|
      @current_job = first_job if current_job?(first_job)

      break_in_months = if second_job
                          GetBreaksInMonths.call(first_job.end_date, second_job.start_date)
                        else
                          GetBreaksInMonths.call(first_job.end_date, nil)
                        end

      @work_history_with_breaks << job_entry(first_job)

      if break?(break_in_months, first_job)
        @work_history_with_breaks << break_entry(break_in_months)
      end
    end

    @work_history_with_breaks
  end

private

  def current_job?(job)
    job.end_date.nil?
  end

  def break?(break_in_months, job)
    break_in_months.positive? && (@current_job.nil? || @current_job.start_date >= job.start_date)
  end

  def job_entry(job)
    { type: :job, entry: job }
  end

  def break_entry(months)
    { type: :break, entry: OpenStruct.new(break_in_months: months) }
  end
end
