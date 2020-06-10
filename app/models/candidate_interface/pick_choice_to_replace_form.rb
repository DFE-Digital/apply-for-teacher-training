module CandidateInterface
  class PickChoiceToReplaceForm
    include ActiveModel::Model

    attr_accessor :id

    validates :id, presence: true
  end
end
