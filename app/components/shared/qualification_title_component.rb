# NOTE: This component is used by both provider and support UIs
class QualificationTitleComponent < ViewComponent::Base
  attr_accessor :qualification

  def initialize(qualification:)
    @qualification = qualification
  end

  def qualification_type
    text = if qualification.gcse?
             gcse_qualification_type
           elsif qualification.degree?
             degree_qualification_type
           elsif qualification.other?
             other_qualification_type
           end

    text || qualification.qualification_type
  end

  def hesa_code
    qualification.qualification_type_hesa_code
  end

private

  def type_for_missing_qualification
    ApplicationQualification.human_attribute_name('qualification_type.gcse')
  end

  def type_for_other_uk_qualification
    qualification.other_uk_qualification_type
  end

  def type_for_non_uk_qualification
    qualification.non_uk_qualification_type
  end

  def type_for_gcse
    ApplicationQualification.human_attribute_name(
      "qualification_type.#{qualification.qualification_type}",
      default: qualification.qualification_type,
    )
  end

  def gcse_qualification_type
    return type_for_missing_qualification if qualification.missing_qualification?
    return type_for_other_uk_qualification if qualification.other_uk_qualification_type.present?
    return type_for_non_uk_qualification if qualification.non_uk_qualification_type.present?

    type_for_gcse
  end

  def other_qualification_type
    return type_for_other_uk_qualification if qualification.other_uk_qualification_type.present?

    type_for_non_uk_qualification if qualification.non_uk_qualification_type.present?
  end

  def degree_qualification_type
    hesa_degree_type = Hesa::DegreeType.find_by_hesa_code(hesa_code)
    if hesa_degree_type
      hesa_degree_type.shortest_display_name
    else
      qualification.qualification_type
    end
  end
end
