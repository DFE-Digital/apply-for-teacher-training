class EmailAddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank? || !value.match?(/@/)
      record.errors[attribute] << I18n.t('activerecord.errors.models.candidate.attributes.email_address.invalid')
    end
  end
end
