class ApplicationQualification < ApplicationRecord
  belongs_to :application_form

  enum level: {
    degree: 'degree',
    gcse: 'gcse',
    other: 'other',
  }

  enum subject: {
    maths: 'maths',
    english: 'english',
    science: 'science',
  }
end
