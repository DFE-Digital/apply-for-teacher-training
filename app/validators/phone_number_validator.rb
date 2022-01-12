class PhoneNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank?
      record.errors.add(attribute, :blank)
    elsif invalid_phone_number_format?(value)
      record.errors.add(attribute, :invalid)
    elsif not_enough_digits?(value)
      record.errors.add(attribute, :too_short)
    elsif too_many_digits?(value)
      record.errors.add(attribute, :too_long)
    end
  end

private

  def invalid_phone_number_format?(value)
    value.match?(/[^ext\-()+.\s 0-9]/)
  end

  def not_enough_digits?(value)
    value.gsub(/[^0-9]/, '').length < 8
  end

  def too_many_digits?(value)
    value.gsub(/[^0-9]/, '').length > 15
  end
end
