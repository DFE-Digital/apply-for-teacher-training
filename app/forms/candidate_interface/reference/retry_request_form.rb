module CandidateInterface
  class Reference::RetryRequestForm
    include ActiveModel::Model

    attr_accessor :email_address

    validates :email_address, presence: true

    def self.build_from_reference(reference)
      new(referee_name: reference.name)
    end
  end
end
