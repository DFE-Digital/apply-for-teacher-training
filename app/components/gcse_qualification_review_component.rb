class GcseQualificationReviewComponent < ActionView::Component::Base
  def initialize(application_qualification:)
    @application_qualification = application_qualification
  end

  def gcse_qualification_rows
    [
      qualification_row,
      award_year_row,
      grade_row,
    ]
  end

private

  attr_reader :application_qualification

  def qualification_row
    {
      key: t('application_form.degree.qualification.label'),
      value: application_qualification.qualification_type.upcase,
      change_path: 'edit_qualification_details_path',
    }
  end

  def award_year_row
    {
      key: 'Year awarded',
      value: application_qualification.award_year,
      change_path: 'edit_qualification_details_path',
    }
  end

  def grade_row
    {
      key: 'Grade',
      value: application_qualification.grade,
      change_path: 'edit_qualification_details_path',
    }
  end
end
