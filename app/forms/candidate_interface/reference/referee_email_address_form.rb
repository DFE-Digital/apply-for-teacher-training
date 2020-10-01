module CandidateInterface
  class Reference::RefereeEmailAddressForm
    include ActiveModel::Model

    attr_accessor :email_address

    validates :email_address, presence: true

    def self.build_from_reference(reference)
      new(email_address: reference.email_address)
    end

    def save(reference)
      return false unless valid?

      reference.update!(email_address: email_address)
    end
  end
end
