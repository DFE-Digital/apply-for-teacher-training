module CandidateInterface
  class VolunteeringExperienceForm
    include ActiveModel::Model

    attr_accessor :experience

    validates :experience, presence: true
  end
end
