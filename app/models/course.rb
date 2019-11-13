class Course < ApplicationRecord
  belongs_to :provider
  has_many :course_options
  has_many :application_choices, through: :course_options

  validates :level, presence: true
  validates :code, uniqueness: { scope: :provider_id }

  CODE_LENGTH = 4

  # This enum is copied verbatim from Find to maintain consistency
  enum level: {
    primary: 'Primary',
    secondary: 'Secondary',
    further_education: 'Further education',
  }, _suffix: :course

  def name_and_code
    "#{name} (#{code})"
  end
end
