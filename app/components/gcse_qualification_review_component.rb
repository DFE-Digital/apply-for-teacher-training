class GcseQualificationReviewComponent < ActionView::Component::Base
  def initialize(application_qualification:, subject:)
    @application_qualification = application_qualification
    @subject = subject
  end

  def gcse_qualification_rows
    [
      qualification_row,
      award_year_row,
      grade_row,
    ]
  end

private

  attr_reader :application_qualification, :subject

  def qualification_row
    {
      key: t('application_form.degree.qualification.label'),
      value: gcse_qualification_types[application_qualification.qualification_type.to_sym],
      change_path: candidate_interface_gcse_details_edit_type_path(subject: subject),
    }
  end

  def award_year_row
    {
      key: 'Year awarded',
      value: application_qualification.award_year,
      change_path: candidate_interface_gcse_details_edit_details_path(subject: subject),
    }
  end

  def grade_row
    {
      key: 'Grade',
      value: application_qualification.grade.upcase,
      change_path: candidate_interface_gcse_details_edit_details_path(subject: subject),
    }
  end

  def gcse_qualification_types
    {
      gcse: 'GCSE',
      gce_o_level: 'GCE O Level',
      scottish_national_5: 'Scottish National 5',
      other_uk: application_qualification.other_uk_qualification_type,
    }
  end
end
