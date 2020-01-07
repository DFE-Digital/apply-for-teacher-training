class QualificationTitleComponent < ActionView::Component::Base
  def initialize(qualification:)
    @qualification = qualification
  end

  def qualification_type
    if @qualification.level == 'gcse' && @qualification.missing_qualification?
      'GCSE'
    else
      @qualification.qualification_type
    end
  end
end
