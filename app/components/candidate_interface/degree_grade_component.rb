class CandidateInterface::DegreeGradeComponent < ApplicationComponent
  include ViewHelper
  include CandidateInterface::Degrees::FormConstants

  attr_reader :model
  delegate :uk?, :country_with_compatible_degrees?, :specified_grades?, :bachelors?, :masters?, :completed?, to: :model

  def initialize(model:)
    @model = model
  end

  def legend_helper
    if show_uk_grades? || show_compatible_country_grades?
      t('application_form.degree.grade.legend.uk', complete: (completed? ? 'is your degree' : 'do you expect to get').to_s)
    elsif model.uk?
      t('application_form.degree.grade.legend.uk_with_optional_grade', complete: (completed? ? 'Did' : 'Will').to_s)
    else
      t('application_form.degree.grade.legend.non_uk', complete: (completed? ? 'Did' : 'Will').to_s)
    end
  end

  def hint
    if show_compatible_country_grades?
      { text: t('.international_hint') }
    end
  end

  def label_helper
    if completed?
      t('application_form.degree.grade.label.completed')
    else
      t('application_form.degree.grade.label.not_completed')
    end
  end

  def hint_helper
    t('application_form.degree.grade.hint.not_completed') unless completed?
  end

  def show_uk_grades?
    uk? && specified_grades?
  end

  def show_compatible_country_grades?
    country_with_compatible_degrees? && bachelors?
  end

  def uk_grades
    if masters?
      UK_MASTERS_DEGREE_GRADES
    elsif bachelors?
      UK_BACHELORS_DEGREE_GRADES
    end
  end

  def compatible_international_grades
    UK_BACHELORS_DEGREE_GRADES
  end
end
