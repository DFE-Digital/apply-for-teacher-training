class CandidateInterface::ApplicationChoices::CurrentRecruitmentCycleComponent < ApplicationComponent
  delegate :academic_year_range_name, to: :application_form

  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def academic_year_title
    I18n.t('candidate_interface.application_choices.current_recruitment_cycle_component.academic_year_title', year_range: academic_year_range_name)
  end
end
