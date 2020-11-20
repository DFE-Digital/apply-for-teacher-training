module TeacherTrainingAPI
  class Provider < TeacherTrainingAPI::Resource
    belongs_to :recruitment_cycle, param: :year
    has_many :courses
  end
end
