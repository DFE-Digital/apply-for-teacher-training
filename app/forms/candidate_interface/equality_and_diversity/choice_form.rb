module CandidateInterface
  class EqualityAndDiversity::ChoiceForm
    include ActiveModel::Model

    attr_accessor :choice

    validates :choice, presence: true

    def initialize(params = {})
      super
      self.choice ||= 'yes'
    end
  end
end
