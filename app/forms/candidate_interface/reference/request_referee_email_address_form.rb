module CandidateInterface
  class Reference::RequestRefereeEmailAddressForm < Reference::RefereeEmailAddressForm
    def email_address_unique
      other_references.each do |other_reference|
        next if other_reference.cancelled? || other_reference.cancelled_at_end_of_cycle?

        errors.add(:email_address, :"duplicate.#{other_reference.feedback_status}") if other_reference.email_address.downcase == email_address.downcase
      end
    end

    def other_references
      reference = ApplicationReference.find(reference_id)
      reference.application_form.application_references.where.not(id: reference_id)
    end
  end
end
