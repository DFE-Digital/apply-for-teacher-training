class QualificationRowComponent < ViewComponent::Base
  validates :qualification, presence: true
  attr_reader :qualification

  def initialize(qualification:)
    @qualification = qualification
  end

private

  def friendly_grade
    if qualification.degree?
      t("application_form.degree.grade.#{qualification.grade}.label", default: qualification.grade)
    else
      qualification.grade
    end
  end
end
