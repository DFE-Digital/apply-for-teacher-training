class DegreesReviewComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:)
    @application_form = application_form
    @degrees = CandidateInterface::DegreeForm.build_all_from_application(
      @application_form,
    )
  end

  def degree_rows(degree)
    [
      qualification_row(degree),
      award_year_row(degree),
      grade_row(degree),
    ]
  end

private

  attr_reader :application_form

  def qualification_row(degree)
    {
      key: t('application_form.degree.qualification.label'),
      value: formatted_qualification(degree),
      action: t('application_form.degree.qualification.change_action'),
      change_path: Rails.application.routes.url_helpers.candidate_interface_degrees_edit_path(degree.id),
    }
  end

  def award_year_row(degree)
    {
      key: t('application_form.degree.award_year.review_label'),
      value: degree.award_year,
      action: t('application_form.degree.award_year.change_action'),
      change_path: Rails.application.routes.url_helpers.candidate_interface_degrees_edit_path(degree.id),
    }
  end

  def grade_row(degree)
    {
      key: t('application_form.degree.grade.review_label'),
      value: formatted_grade(degree),
      action: t('application_form.degree.grade.change_action'),
      change_path: Rails.application.routes.url_helpers.candidate_interface_degrees_edit_path(degree.id),
    }
  end

  def formatted_qualification(degree)
    [degree.title, degree.institution_name]
  end

  def formatted_grade(degree)
    if degree.predicted_grade.present?
      "#{degree.predicted_grade} (Predicted)"
    elsif degree.other_grade.present?
      degree.other_grade
    else
      t("application_form.degree.grade.#{degree.grade}.label")
    end
  end
end
