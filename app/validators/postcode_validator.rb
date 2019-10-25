class PostcodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    postcode = UKPostcode.parse(value)

    unless postcode.full_valid?
      record.errors[attribute] << I18n.t('activemodel.errors.models.candidate_interface/contact_details_form.attributes.postcode.invalid')
    end
  end
end
