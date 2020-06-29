class QualificationSubjectComponent < ViewComponent::Base
  def initialize(qualification:)
    @qualification = qualification
  end

  def subject
    @qualification.subject&.titleize
  end

  def hesa_code
    @qualification.subject_hesa_code
  end
end
