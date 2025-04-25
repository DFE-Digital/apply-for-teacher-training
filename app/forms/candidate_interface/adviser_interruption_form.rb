module CandidateInterface
  class AdviserInterruptionForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :application_form
    attribute :proceed_to_request_adviser

    validates :proceed_to_request_adviser, presence: true

    def save
      return false if invalid?

      if proceed_to_request_adviser?
        application_form.update(adviser_interruption_response: true)
      else
        application_form.update(adviser_interruption_response: false)
      end
    end

    def proceed_to_request_adviser?
      proceed_to_request_adviser == 'yes'
    end
  end
end
