class EnglishLanguageProficiency < ApplicationRecord
  belongs_to :application_form
  belongs_to :efl_qualification, polymorphic: true

  enum qualification_status: {
    yes: 'yes',
    no: 'no',
    not_needed: 'not_needed',
  }
end
