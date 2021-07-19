class CandidateInterface::DeadlineBannerComponent < ViewComponent::Base
  attr_accessor :phase, :flash_empty

  def initialize(application_form:, flash_empty:)
    @application_form = application_form
    @flash_empty = flash_empty
  end

  def deadline
    if apply_1? && !eligible_to_apply_again?
      apply_1_deadline
    else
      apply_2_deadline
    end
  end

  def academic_year
    "#{application_form_recruitment_cycle_year} to #{application_form_recruitment_cycle_year + 1}"
  end

  def render?
    flash_empty &&
      (show_apply_1_deadline_banner? || show_apply_2_deadline_banner?)
  end

private

  def show_apply_1_deadline_banner?
    apply_1? && CycleTimetable.show_apply_1_deadline_banner?
  end

  def show_apply_2_deadline_banner?
    apply_2? && CycleTimetable.show_apply_2_deadline_banner? || eligible_to_apply_again?
  end

  def apply_1?
    @application_form.phase == 'apply_1'
  end

  def apply_2?
    @application_form.phase == 'apply_2'
  end

  def eligible_to_apply_again?
    apply_1? && CycleTimetable.show_apply_2_deadline_banner? && @application_form.ended_without_success?
  end

  def apply_1_deadline
    CycleTimetable.date(:apply_1_deadline).to_s(:govuk_date)
  end

  def apply_2_deadline
    CycleTimetable.date(:apply_2_deadline).to_s(:govuk_date)
  end

  def application_form_recruitment_cycle_year
    @application_form.recruitment_cycle_year
  end
end
