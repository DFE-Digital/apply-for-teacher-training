class Adviser::TeachingSubject < ApplicationRecord
  include Discard::Model

  self.table_name = 'adviser_teaching_subjects'

  validates :title, :external_identifier, presence: true
  validates :external_identifier, uniqueness: true

  enum :level, {
    primary: 'primary',
    secondary: 'secondary',
  }, suffix: true, validate: true
end
