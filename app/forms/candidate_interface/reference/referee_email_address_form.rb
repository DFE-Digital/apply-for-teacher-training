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

    def personal_email_address?(reference)
      EmailChecker.new(reference.email_address).personal?
    end

  private

    def email_address_unique
      reference = ApplicationReference.find(reference_id)
      current_email_addresses = (reference.application_form.application_references.creation_order.map(&:email_address) - [reference.email_address]).compact
      return true if current_email_addresses.blank? || email_address.blank?

      errors.add(:email_address, :duplicate) if current_email_addresses.map(&:downcase).include?(email_address.downcase)
    end

    def email_address_not_own
      reference = ApplicationReference.find(reference_id)
      return if reference.application_form.nil?

      candidate_email_address = reference.application_form.candidate.email_address

      errors.add(:email_address, :own) if email_address == candidate_email_address
    end
  end
end
