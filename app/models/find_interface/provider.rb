class FindInterface::Provider < FindInterface::Base
  belongs_to :recruitment_cycle, param: :recruitment_cycle_year
  has_many :courses, param: :course_code
end
