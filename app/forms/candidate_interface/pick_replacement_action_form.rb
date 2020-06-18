module CandidateInterface
  class PickReplacementActionForm
    include ActiveModel::Model

    attr_accessor :replacement_action

    validates :replacement_action, presence: true
  end
end
