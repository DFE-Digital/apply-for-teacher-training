module CandidateInterface
  class DegreesReviewComponent < ViewComponent::Base
    validates :application_form, presence: true

    def initialize(application_form:, editable: true, heading_level: 2, show_incomplete: false, missing_error: false)
      @application_form = application_form
      @degrees = CandidateInterface::DegreeForm.build_all_from_application(
        @application_form,
      )
      @editable = editable
      @heading_level = heading_level
      @show_incomplete = show_incomplete
      @missing_error = missing_error
    end

    def degree_rows(degree)
      [
        degree_type_row(degree),
        subject_row(degree),
        institution_row(degree),
        start_year_row(degree),
        award_year_row(degree),
        grade_row(degree),
      ]
    end

    def show_missing_banner?
      @show_incomplete && !@application_form.degrees_completed && @editable
    end

  private

    attr_reader :application_form

    def degree_type_row(degree)
      {
        key: t('application_form.degree.qualification_type.review_label'),
        value: degree.qualification_type,
        action: generate_action(degree: degree, attribute: t('application_form.degree.qualification.change_action')),
        change_path: Rails.application.routes.url_helpers.candidate_interface_edit_degree_type_path(degree.id),
      }
    end

    def subject_row(degree)
      {
        key: t('application_form.degree.subject.review_label'),
        value: degree.subject,
        action: generate_action(degree: degree, attribute: t('application_form.degree.subject.change_action')),
        change_path: Rails.application.routes.url_helpers.candidate_interface_edit_degree_subject_path(degree.id),
      }
    end

    def institution_row(degree)
      {
        key: t('application_form.degree.institution_name.review_label'),
        value: degree.institution_name,
        action: generate_action(degree: degree, attribute: t('application_form.degree.institution_name.change_action')),
        change_path: Rails.application.routes.url_helpers.candidate_interface_edit_degree_institution_path(degree.id),
      }
    end

    def start_year_row(degree)
      {
        key: t('application_form.degree.start_year.review_label'),
        value: degree.start_year,
        action: generate_action(degree: degree, attribute: t('application_form.degree.start_year.change_action')),
        change_path: Rails.application.routes.url_helpers.candidate_interface_edit_degree_year_path(degree.id),
      }
    end

    def award_year_row(degree)
      {
        key: t('application_form.degree.award_year.review_label'),
        value: degree.award_year,
        action: generate_action(degree: degree, attribute: t('application_form.degree.award_year.change_action')),
        change_path: Rails.application.routes.url_helpers.candidate_interface_edit_degree_year_path(degree.id),
      }
    end

    def grade_row(degree)
      {
        key: t('application_form.degree.grade.review_label'),
        value: formatted_grade(degree),
        action: generate_action(degree: degree, attribute: t('application_form.degree.grade.change_action')),
        change_path: Rails.application.routes.url_helpers.candidate_interface_edit_degree_grade_path(degree.id),
      }
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

    def generate_action(degree:, attribute: '')
      "#{attribute.presence} for #{degree.qualification_type}, #{degree.subject}, #{degree.institution_name}, #{degree.award_year}"
    end
  end
end
