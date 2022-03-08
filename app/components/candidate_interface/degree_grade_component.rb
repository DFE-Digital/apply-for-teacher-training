class CandidateInterface::DegreeGradeComponent < ViewComponent::Base
  include ViewHelper
  attr_reader :wizard, :uk_or_non_uk, :completed

  UK_DEGREE_GRADES = [
    'First-class honours',
    'Upper second-class honours (2:1)',
    'Lower second-class honours (2:2)',
    'Third-class honours',
    'Pass',
    'Other',
  ].freeze

  def initialize(wizard:)
    @wizard = wizard
    @uk_or_non_uk = wizard.uk_or_non_uk
    @completed = wizard.completed
  end

  def legend_helper
    if uk_or_non_uk == 'uk'
      t('application_form.degree.grade.legend.uk', complete: (completed == 'Yes' ? 'is your degree' : 'do you expect to get').to_s)
    else
      t('application_form.degree.grade.legend.non_uk', complete: (completed == 'Yes' ? 'Did' : 'Will').to_s)
    end
  end

  def label_helper
    if completed == 'Yes'
      t('application_form.degree.grade.label.completed')
    else
      t('application_form.degree.grade.label.not_completed')
    end
  end

  def hint_helper
    t('application_form.degree.grade.hint.not_completed') if completed != 'Yes'
  end
end
