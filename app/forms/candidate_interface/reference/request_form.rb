module CandidateInterface
  class Reference::RequestForm
    include ActiveModel::Model

    attr_accessor :request_now, :referee_name

    validates :request_now, presence: true
    validates :referee_name, presence: true

    def self.build_from_reference(reference)
      new(referee_name: reference.name)
    end
  end
end
