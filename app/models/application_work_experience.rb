class ApplicationWorkExperience < ApplicationExperience
  belongs_to :application_form, touch: true

  validates :commitment, presence: true

  enum commitment: {
    full_time: 'Full-time',
    part_time: 'Part-time',
  }

  audited associated_with: :application_form

  def next_work_breaks_in_months
    next_work = application_form.application_work_experiences
                  .order(:start_date)
                  .find_by(['start_date > ?', start_date])

    next_work_start_date = next_work ? next_work.start_date : Time.zone.today
    current_work_end_date = end_date || Time.zone.today

    gap_in_months(current_work_end_date, next_work_start_date)
  end

private

  def gap_in_months(start_date, end_date)
    month_gap = (end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month) - 1
    [month_gap, 0].max
  end
end
