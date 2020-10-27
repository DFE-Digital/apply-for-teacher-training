# NOTE: This component is used by both provider and support UIs
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
