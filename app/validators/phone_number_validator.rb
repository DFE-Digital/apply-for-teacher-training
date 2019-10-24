class PhoneNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank? || is_invalid_phone_number_format?(value)
      record.errors[attribute] << I18n.t('activemodel.errors.models.candidate_interface/contact_details_form.attributes.phone_number.invalid')
    end
  end

private

  def is_invalid_phone_number_format?(value)
    value.match?(/[^ext()+\. 0-9]/)
  end
end
