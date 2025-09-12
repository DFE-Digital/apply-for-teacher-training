class PreviousTeacherTraining < ApplicationRecord
  belongs_to :application_form

  enum :started, {
    yes: 'yes',
    no: 'no',
  }
end
