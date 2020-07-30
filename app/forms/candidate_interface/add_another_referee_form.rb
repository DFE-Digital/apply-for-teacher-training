module CandidateInterface
  class AddAnotherRefereeForm
    include ActiveModel::Model

    attr_accessor :add_another_referee
    validates :add_another_referee, presence: true

    def add_another_referee?
      add_another_referee == 'yes'
    end
  end
end
