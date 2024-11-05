module CandidateInterface
  class Reference::RequestRefereeEmailAddressForm < Reference::RefereeEmailAddressForm
    def email_address_unique
      return true if email_address.blank?

      other_references
        .reject { |reference| reference.cancelled? || reference.cancelled_at_end_of_cycle? }
        .select { |reference| reference.email_address.to_s.downcase == email_address.downcase }.each do |other_reference|
        errors.add(:email_address, :"duplicate.#{other_reference.feedback_status}")
      end
    end

    def other_references
      reference = ApplicationReference.find(reference_id)
      reference.application_form.application_references.creation_order.where.not(id: reference_id)
    end
  end
end
