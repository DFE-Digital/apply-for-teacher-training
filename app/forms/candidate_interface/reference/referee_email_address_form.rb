module CandidateInterface
  class Reference::RefereeEmailAddressForm
    include ActiveModel::Model

    attr_accessor :email_address, :application_form_id

    validates :email_address, presence: true,
                              email_address: true,
                              length: { maximum: 100 }

    validates :application_form_id, presence: true

    validate :email_address_unique?

    def self.build_from_reference(reference)
      new(email_address: reference.email_address)
    end

    def save(reference)
      return false unless valid?

      reference.update!(email_address: email_address)
    end

  private

    def email_address_unique?
      application_form = ApplicationForm.find(application_form_id)
      current_email_addresses = application_form.application_references.map(&:email_address).compact
      return true if current_email_addresses.blank?

      errors.add(:email_address, :duplicate) if current_email_addresses.map(&:downcase).include?(email_address)
    end
  end
end
