module CandidateInterface
  class References::RelationshipStep < DfE::WizardStep
    include Rails.application.routes.url_helpers
    attr_accessor :relationship
    delegate :reference_process, :application_choice, :return_to_path, :reference,
      to: :wizard

    validates :relationship, presence: true, length: { maximum: 500 }

    def self.permitted_params
      [:relationship]
    end

    def previous_step
      :reference_email_address
    end

    def next_step
      return_to_path || process_next_path
    end

    private

    def process_next_path
      case reference_process
      when 'candidate-details'
        candidate_interface_references_review_path(reference_process)
      when 'accept-offer'
        candidate_interface_accept_offer_path(application_choice)
      when 'request-reference'
        candidate_interface_new_references_review_path(
          reference_process,
          reference
        )
      end
    end
  end
end
