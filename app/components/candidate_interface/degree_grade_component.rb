class CandidateInterface::DegreeGradeComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :model
  delegate :uk?, :country_with_compatible_degrees?, :bachelors?, :masters?, to: :model

  UK_BACHELORS_DEGREE_GRADES = [
    'First-class honours',
    'Upper second-class honours (2:1)',
    'Lower second-class honours (2:2)',
    'Third-class honours',
    'Pass',
    'Other',
  ].freeze

  UK_MASTERS_DEGREE_GRADES = %w[Distinction Merit Pass Other].freeze

  def initialize(model:)
    @model = model
  end

  def legend_helper
    if model.uk? && model.specified_grades?
      t('application_form.degree.grade.legend.uk', complete: (model.completed? ? 'is your degree' : 'do you expect to get').to_s)
    elsif model.uk? && !model.specified_grades?
      t('application_form.degree.grade.legend.uk_with_optional_grade', complete: (model.completed? ? 'Did' : 'Will').to_s)
    else
      t('application_form.degree.grade.legend.non_uk', complete: (model.completed? ? 'Did' : 'Will').to_s)
    end
  end

  def label_helper
    if model.completed?
      t('application_form.degree.grade.label.completed')
    else
      t('application_form.degree.grade.label.not_completed')
    end
  end

  def hint_helper
    t('application_form.degree.grade.hint.not_completed') unless model.completed?
  end

  def specific_grade_options?
    masters? || bachelors?
  end

  def show_uk_grades?
    uk? && specific_grade_options?
  end

  def show_compatible_country_grades?
    country_with_compatible_degrees? && bachelors?
  end

  def uk_grades
    if model.masters?
      UK_MASTERS_DEGREE_GRADES
    else
      UK_BACHELORS_DEGREE_GRADES
    end
  end

  def compatible_international_grades
    UK_BACHELORS_DEGREE_GRADES
  end
end
