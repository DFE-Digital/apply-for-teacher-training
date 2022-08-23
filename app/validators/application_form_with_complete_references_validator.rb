class ApplicationFormWithCompleteReferencesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless record.completed?

    application_form = value

    record.errors.add(attribute, :incomplete_references) if invalid_references?(application_form)
  end

  def invalid_references?(application_form)
    !application_form.complete_references_information? ||
      application_form.application_references.any? do |application_reference|
        referee_email_address_form = CandidateInterface::Reference::RefereeEmailAddressForm.new(
          email_address: application_reference.email_address,
          reference_id: application_reference.id,
        )

        referee_relationship_form = CandidateInterface::Reference::RefereeRelationshipForm.new(
          relationship: application_reference.relationship,
        )

        referee_email_address_form.invalid? || referee_relationship_form.invalid?
      end
  end
end
