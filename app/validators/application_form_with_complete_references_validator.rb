class ApplicationFormWithCompleteReferencesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    application_form = value.is_a?(ApplicationForm) ? value : value.application_form

    record.errors.add(attribute, :incomplete_references) if invalid_references?(application_form)
  end

  def invalid_references?(application_form)
    application_form.application_references.any? do |application_reference|
      !CandidateInterface::Reference::SubmitRefereeForm.new(
        submit: 'yes',
        reference_id: application_reference.id,
      ).valid?
    end
  end
end
