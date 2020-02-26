module CandidateInterface
  class PickStudyModeForm
    include ActiveModel::Model

    attr_accessor :provider_id, :course_id, :study_mode
  end
end
