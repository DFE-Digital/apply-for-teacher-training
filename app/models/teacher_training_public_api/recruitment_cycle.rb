module TeacherTrainingPublicAPI
  class RecruitmentCycle < TeacherTrainingPublicAPI::Resource
    has_many :providers, dependent: nil
  end
end
