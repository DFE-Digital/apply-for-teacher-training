class CandidateInterface::DegreeGradeComponent < ViewComponent::Base
  include ViewHelper
  attr_reader :model

  UK_DEGREE_GRADES = [
    'First-class honours',
    'Upper second-class honours (2:1)',
    'Lower second-class honours (2:2)',
    'Third-class honours',
    'Pass',
    'Other',
  ].freeze

  def initialize(model:)
    @model = model
  end

  def legend_helper
    if model.uk?
      t('application_form.degree.grade.legend.uk', complete: (model.completed? ? 'is your degree' : 'do you expect to get').to_s)
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
end
