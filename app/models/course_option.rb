class CourseOption < ApplicationRecord
  belongs_to :course
  belongs_to :site

  validates :vacancy_status, presence: true
end
