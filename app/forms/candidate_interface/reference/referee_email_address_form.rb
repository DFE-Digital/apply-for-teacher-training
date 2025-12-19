module CandidateInterface
  class Reference::RefereeEmailAddressForm
    include ActiveModel::Model

    attr_accessor :email_address, :reference_id

    validates :email_address, presence: true,
                              valid_for_notify: true,
                              length: { maximum: 100 }

    validates :reference_id, presence: true

    validate :email_address_unique
    validate :email_address_not_own

    def self.build_from_reference(reference)
      new(
        email_address: reference.email_address&.downcase,
        reference_id: reference.id,
      )
    end

    def save(reference)
      return false unless valid?

      ApplicationForm.with_unsafe_application_choice_touches do
        reference.update!(email_address:)
      end
    end

    def show_interruption?(reference)
      professional_email_address_preferred?(reference) && personal_email_address?(reference)
    end

  private

    def personal_email_address?(reference)
      EmailChecker.new(reference.email_address).personal?
    end

    def professional_email_address_preferred?(reference)
      !reference.character?
    end

    def email_address_unique
      reference = ApplicationReference.find(reference_id)
      all_emails = reference.application_form.application_references.creation_order.map(&:email_address).compact

      # Remove reference.email_address to prevent validation counting itself as a duplicate - case insensitive
      current_email_addresses = all_emails.reject { |address| address&.casecmp?(reference.email_address) }

      return true if current_email_addresses.blank? || email_address.blank?

      if current_email_addresses.any? { |address| address.casecmp?(email_address) }
        errors.add(:email_address, :duplicate)
      end
    end

    def email_address_not_own
      reference = ApplicationReference.find(reference_id)
      return if reference.application_form.nil?

      candidate_email_address = reference.application_form.candidate.email_address

      errors.add(:email_address, :own) if email_address == candidate_email_address
    end
  end
end
