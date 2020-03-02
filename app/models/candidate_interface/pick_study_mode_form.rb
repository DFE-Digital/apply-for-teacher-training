module CandidateInterface
  class PickStudyModeForm
    include ActiveModel::Model

    attr_accessor :provider_id, :course_id, :study_mode
    validates :study_mode, presence: true
  end
end
