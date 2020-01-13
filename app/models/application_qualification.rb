class ApplicationQualification < ApplicationRecord
  belongs_to :application_form, touch: true

  scope :degrees, -> { where level: 'degree' }
  scope :gcses, -> { where level: 'gcse' }
  scope :other, -> { where level: 'other' }

  enum level: {
    degree: 'degree',
    gcse: 'gcse',
    other: 'other',
  }

  audited associated_with: :application_form

  def missing_qualification?
    qualification_type == 'missing'
  end
end
