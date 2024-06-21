module CandidateInterface
  class References::EmailAddressStep < DfE::Wizard::Step
    include Rails.application.routes.url_helpers
    attr_accessor :email_address
    delegate :reference_process, :reference, :return_to_path,
      :application_choice, to: :wizard

    validates :email_address, presence: true,
                              valid_for_notify: true,
                              length: { maximum: 100 }

    validates :reference, presence: true

    validate :email_address_unique
    validate :email_address_not_own


    def self.permitted_params
      [:email_address]
    end

    def previous_step
      :reference_name
    end

    def next_step
      # candidate_interface
      # references
      # reference_name
      #return_to_path || :reference_relationship

      return_to_path || process_next_path
    end

    #def next_step_path_arguments
    #  reference.id
    #end

    private

    def process_next_path
      case reference_process
      when 'candidate-details'
        candidate_interface_references_relationship_path(
          reference_process,
          reference.id,
        )
      when 'accept-offer'
        candidate_interface_references_relationship_path(
          reference_process,
          reference.id,
          params: { application_id: application_choice&.id },
        )
      when 'request-reference'
        candidate_interface_references_relationship_path(
          reference_process,
          reference.id,
        )
      end
    end

    def email_address_unique
      ### Should we pass the reference record to the wizard?
      current_email_addresses = (reference.application_form.application_references.creation_order.map(&:email_address) - [reference.email_address]).compact
      return true if current_email_addresses.blank? || email_address.blank?

      errors.add(:email_address, :duplicate) if current_email_addresses.map(&:downcase).include?(email_address.downcase)
    end

    def email_address_not_own
      return if reference.application_form.nil?

      candidate_email_address = reference.application_form.candidate.email_address

      errors.add(:email_address, :own) if email_address == candidate_email_address
    end
  end
end
