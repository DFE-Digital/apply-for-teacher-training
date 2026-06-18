class CandidateInterface::ApplicationChoices::CurrentRecruitmentCycleComponent < ApplicationComponent
  delegate :academic_year_range_name, to: :application_form

  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def academic_year_title
    "Courses for the #{academic_year_range_name} academic year"
  end

  def application_choices
    CandidateInterface::SortApplicationChoices.call(
      application_choices: application_form.application_choices.for_sorting,
    )
  end
end
