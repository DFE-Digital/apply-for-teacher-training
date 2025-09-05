class PreviousTeacherTrainingForm < ApplicationRecord
  belongs_to :application_form

  class Start < PreviousTeacherTrainingForm
    attr_accessor :choice

    validates :code, presence: true
  end
end
