class PhoneNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank?
      record.errors.add(attribute, :blank)
    elsif is_invalid_phone_number_format?(value)
      record.errors.add(attribute, :invalid)
    end
  end

private

  def is_invalid_phone_number_format?(value)
    value.match?(/[^ext()+\. 0-9]/)
  end
end
