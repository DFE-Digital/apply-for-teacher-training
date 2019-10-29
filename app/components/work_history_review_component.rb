class WorkHistoryReviewComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:)
    @application_form = application_form
  end

  def work_experience_rows(work)
    [
      job_row(work),
      type_row(work),
      description_row(work),
      dates_row(work),
    ]
      .compact
  end

  def no_work_experience_rows
    [
      {
        key: 'Explanation of why you’ve been out of the workplace',
        value: 'Not entered',
        action: 'explanation',
        change_path: '#'
      }
    ]
  end

private

  attr_reader :application_form

  def job_row(work)
    {
      key: 'Job',
      DANGEROUS_html_value: [work.role, work.organisation]
        .map { |field| sanitize(field, tags: []) }
        .join('<br>'),
      action: 'job',
      change_path: '#',
    }
  end

  def type_row(work)
    {
      key: 'Type',
      value: work.commitment.dasherize.humanize,
      action: 'type',
      change_path: '#',
    }
  end

  def description_row(work)
    {
      key: 'Description',
      value: work.details,
      action: 'description',
      change_path: '#',
    }
  end

  def dates_row(work)
    {
      key: 'Dates',
      value: "#{formatted_start_date(work)} - #{formatted_end_date(work)}",
      action: 'description',
      change_path: '#',
    }
  end

  def formatted_start_date(work)
    work.start_date.strftime('%B %Y')
  end

  def formatted_end_date(work)
    return 'Present' if work.end_date.nil?

    work.end_date.strftime('%B %Y')
  end
end
