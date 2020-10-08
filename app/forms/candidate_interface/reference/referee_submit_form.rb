module CandidateInterface
  class Reference::RefereeSubmitForm
    include ActiveModel::Model

    attr_accessor :submit

    validates :submit, presence: true
  end
end
