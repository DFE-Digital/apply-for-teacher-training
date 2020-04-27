class QualificationTitleComponent < ViewComponent::Base
  def initialize(qualification:)
    @qualification = qualification
  end

  def qualification_type
    if @qualification.level == 'gcse'
      return type_for_missing_qualification if @qualification.missing_qualification?
      return type_for_other_uk_qualification if @qualification.other_uk_qualification_type.present?

      return type_for_gcse
    end

    @qualification.qualification_type
  end

private

  def type_for_missing_qualification
    ApplicationQualification.human_attribute_name('qualification_type.gcse')
  end

  def type_for_other_uk_qualification
    I18n.t('application_form.gcse.qualification_types.other_uk')
      .concat(': ', @qualification.other_uk_qualification_type)
  end

  def type_for_gcse
    ApplicationQualification.human_attribute_name(
      "qualification_type.#{@qualification.qualification_type}",
      default: @qualification.qualification_type,
    )
  end
end
