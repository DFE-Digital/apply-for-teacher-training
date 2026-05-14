class CandidateInterface::ApplicationChoices::MidCycleUnsuccessfulContentComponent < ApplicationComponent
  def initialize(application_form:)
    @application_form = application_form
  end

  attr_reader :application_form

  delegate :total_application_limit, :in_progress_limit, to: :application_form

  def show_total_applications_limit?
    total_application_limit <= in_progress_limit
  end

  def apply_reopens_date_text
    application_form.recruitment_cycle_timetable.apply_reopens_at.to_fs(:month_and_year)
  end
end
