class EnglishProficiency < ApplicationRecord
  belongs_to :application_form
  belongs_to :efl_qualification, polymorphic: true, optional: true, dependent: :destroy

  enum qualification_status: {
    has_qualification: 'has_qualification',
    no_qualification: 'no_qualification',
    qualification_not_needed: 'qualification_not_needed',
  }
end
