class OtherQualificationsReviewComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:)
    @application_form = application_form
    @qualifications = CandidateInterface::OtherQualificationForm.build_all_from_application(
      @application_form,
    )
  end

  def other_qualifications_rows(qualification)
    [
      qualification_row(qualification),
      award_year_row(qualification),
      grade_row(qualification),
    ]
  end

private

  attr_reader :application_form

  def qualification_row(qualification)
    {
      key: t('application_form.other_qualification.qualification.label'),
      DANGEROUS_html_value: formatted_qualification(qualification),
      action: t('application_form.other_qualification.qualification.change_action'),
      change_path: '#',
    }
  end

  def award_year_row(qualification)
    {
      key: t('application_form.other_qualification.award_year.review_label'),
      value: qualification.award_year,
      action: t('application_form.other_qualification.award_year.change_action'),
      change_path: '#',
    }
  end

  def grade_row(qualification)
    {
      key: t('application_form.other_qualification.grade.label'),
      value: qualification.grade,
      action: t('application_form.other_qualification.grade.change_action'),
      change_path: '#',
    }
  end

  def formatted_qualification(qualification)
    [qualification.title, qualification.institution_name]
      .map { |line| sanitize(line, tags: []) }
      .join('<br>')
  end
end
