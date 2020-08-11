class QualificationTitleComponent < ViewComponent::Base
  def initialize(qualification:)
    @qualification = qualification
  end

  def qualification_type
    if @qualification.level == 'gcse'
      return type_for_missing_qualification if @qualification.missing_qualification?
      return type_for_other_uk_qualification if @qualification.other_uk_qualification_type.present?
      return type_for_non_uk_qualification if @qualification.non_uk_qualification_type.present?

      return type_for_gcse
    elsif @qualification.degree?
      return type_for_degree
    elsif @qualification.level == 'other'
      return type_for_other_uk_qualification if @qualification.other_uk_qualification_type.present?
      return type_for_non_uk_qualification if @qualification.non_uk_qualification_type.present?
    end

    @qualification.qualification_type
  end

  def type_for_degree
    hesa_degree_type = Hesa::DegreeType.find_by_hesa_code(hesa_code)
    if hesa_degree_type
      hesa_degree_type.shortest_display_name
    else
      @qualification.qualification_type
    end
  end

  def hesa_code
    @qualification.qualification_type_hesa_code
  end

private

  def type_for_missing_qualification
    ApplicationQualification.human_attribute_name('qualification_type.gcse')
  end

  def type_for_other_uk_qualification
    I18n.t('application_form.gcse.qualification_types.other_uk')
      .concat(': ', @qualification.other_uk_qualification_type)
  end

  def type_for_non_uk_qualification
    I18n.t('application_form.gcse.qualification_types.non_uk')
      .concat(': ', @qualification.non_uk_qualification_type)
  end

  def type_for_gcse
    ApplicationQualification.human_attribute_name(
      "qualification_type.#{@qualification.qualification_type}",
      default: @qualification.qualification_type,
    )
  end
end
