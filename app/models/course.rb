class Course < ApplicationRecord
  belongs_to :provider
  has_many :course_options
  has_many :application_choices, through: :course_options
  belongs_to :accrediting_provider, class_name: 'Provider', optional: true

  validates :level, presence: true
  validates :code, uniqueness: { scope: :provider_id }

  scope :visible_to_candidates, -> { where(exposed_in_find: true) }
  scope :applyable, -> { visible_to_candidates.where(open_on_apply: true) }

  CODE_LENGTH = 4

  # This enum is copied verbatim from Find to maintain consistency
  enum level: {
    primary: 'Primary',
    secondary: 'Secondary',
    further_education: 'Further education',
  }, _suffix: :course

  # also copied from Find
  enum study_mode: {
    full_time: 'F',
    part_time: 'P',
    full_time_or_part_time: 'B',
  }

  def name_and_code
    "#{name} (#{code})"
  end
end
