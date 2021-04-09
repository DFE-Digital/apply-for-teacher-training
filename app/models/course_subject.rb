class CourseSubject < ApplicationRecord
  belongs_to :course
  belongs_to :subject

  validates :course_id, uniqueness: { scope: :subject_id }
end
