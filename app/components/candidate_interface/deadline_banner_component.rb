class CandidateInterface::DeadlineBannerComponent < ViewComponent::Base
  attr_accessor :phase, :flash_empty

  def initialize(application_form:, flash_empty:)
    @application_form = application_form
    @flash_empty = flash_empty
  end

  def render?
    flash_empty && CycleTimetable.show_apply_deadline_banner?(@application_form)
  end

  def deadline
    {
      date: CycleTimetable.date(:apply_deadline).to_fs(:govuk_date),
      time: CycleTimetable.date(:apply_deadline).to_fs(:govuk_time),
    }
  end

  def academic_year
    "#{application_form_recruitment_cycle_year} to #{application_form_recruitment_cycle_year + 1}"
  end

private

  def application_form_recruitment_cycle_year
    @application_form.recruitment_cycle_year
  end
end
