class QualificationTitleComponent < ActionView::Component::Base
  def initialize(qualification:)
    @qualification = qualification
  end
end
