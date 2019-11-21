module CandidateInterface
  class CourseChosenForm
    include ActiveModel::Model

    attr_accessor :choice

    validates :choice, presence: true
  end
end
