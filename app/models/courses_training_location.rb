class CoursesTrainingLocation < ActiveRecord::Base
  belongs_to :training_location
  belongs_to :course
end
