module CandidateInterface
  class AdviserInterruptionForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :application_form
    attribute :proceed_to_request_adviser

    validates :proceed_to_request_adviser, presence: true

    def proceed_to_request_adviser?
      proceed_to_request_adviser == 'yes'
    end
  end
end
