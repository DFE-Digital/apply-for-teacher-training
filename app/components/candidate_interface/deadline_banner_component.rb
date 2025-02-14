class CandidateInterface::DeadlineBannerComponent < ViewComponent::Base
  attr_accessor :phase, :flash_empty

  def initialize(application_form:, flash_empty:)
    @application_form = application_form
    @flash_empty = flash_empty
    @timetable = @application_form.recruitment_cycle_timetable
  end

  def render?
    flash_empty && show_appy_deadline_banner?
  end

  def deadline
    {
      date: @timetable.apply_deadline_at.to_fs(:govuk_date),
      time: @timetable.apply_deadline_at.to_fs(:govuk_time),
    }
  end

  def academic_year
    @timetable.academic_year_range_name
  end

  def show_appy_deadline_banner?
    !@application_form.successful? &&
      Time.zone.now.between?(@timetable.apply_deadline_at - 12.weeks, @timetable.apply_deadline_at)
  end
end
