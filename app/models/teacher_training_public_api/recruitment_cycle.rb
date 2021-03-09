module TeacherTrainingPublicAPI
  class RecruitmentCycle < TeacherTrainingPublicAPI::Resource
    has_many :providers
  end
end
