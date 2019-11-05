class DegreesReviewComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:)
    @application_form = application_form
    @degrees_form = CandidateInterface::DegreesForm.build_all_from_application(
      @application_form,
    )
  end

  def degree_form_rows(degree_form)
    [
      qualification_row(degree_form),
      award_year_row(degree_form),
      grade_row(degree_form),
    ]
  end

private

  attr_reader :application_form

  def qualification_row(degree_form)
    {
      key: t('application_form.degree.qualification.label'),
      DANGEROUS_html_value: formatted_qualification(degree_form),
      action: t('application_form.degree.qualification.change_action'),
      change_path: Rails.application.routes.url_helpers.candidate_interface_degrees_edit_path(degree_form.id),
    }
  end

  def award_year_row(degree_form)
    {
      key: t('application_form.degree.award_year.review_label'),
      value: degree_form.award_year,
      action: t('application_form.degree.award_year.change_action'),
      change_path: Rails.application.routes.url_helpers.candidate_interface_degrees_edit_path(degree_form.id),
    }
  end

  def grade_row(degree_form)
    {
      key: t('application_form.degree.grade.review_label'),
      value: formatted_grade(degree_form.grade, degree_form.predicted_grade),
      action: t('application_form.degree.grade.change_action'),
      change_path: Rails.application.routes.url_helpers.candidate_interface_degrees_edit_path(degree_form.id),
    }
  end

  def formatted_qualification(degree_form)
    [degree_form.title, degree_form.institution_name]
      .map { |line| sanitize(line, tags: []) }
      .join('<br>')
  end

  def formatted_grade(grade, predicted_grade)
    case grade
    when 'first', 'upper_second', 'lower_second', 'third'
      t("application_form.degree.grade.#{grade}.label")
    else
      predicted_grade ? "#{grade} (Predicted)" : grade
    end
  end
end
