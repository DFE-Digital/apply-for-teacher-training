# NOTE: This component is used by both provider and support UIs
class QualificationGradeComponent < ViewComponent::Base
  def initialize(qualification:)
    @qualification = qualification
  end

  def grade
    if @qualification.predicted_grade?
      "#{@qualification.grade} (predicted)"
    else
      @qualification.grade.presence || 'Not entered'
    end
  end

  def hesa_code
    @qualification.grade_hesa_code
  end
end
