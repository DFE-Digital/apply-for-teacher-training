class FindInterface::Subject < FindInterface::Base
  has_many :course_subjects
  has_many :courses, through: :course_subjects
  belongs_to :subject_area, foreign_key: :type, inverse_of: :subjects, shallow_path: true
end
