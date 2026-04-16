class VisaExplanationValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, application_choice)
    return unless application_choice.visa_expires_soon?
    return if application_choice.visa_explanation

    record.errors.add(attribute, :visa_explanation)
  end
end
