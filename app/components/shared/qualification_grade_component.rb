# NOTE: This component is used by both provider and support UIs
class QualificationGradeComponent < ApplicationComponent
  def initialize(qualification:)
    @qualification = qualification
  end

  def grade
    if @qualification.predicted_grade?
      "#{@qualification.grade} (predicted)"
    else
      @qualification.grade.presence
    end
  end

  def hesa_code
    @qualification.grade_hesa_code
  end
end
