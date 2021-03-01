module CandidateInterface
  class DegreesReviewComponent < ViewComponent::Base
    include ViewHelper

    def initialize(application_form:, editable: true, heading_level: 2, show_incomplete: false, missing_error: false)
      @application_form = application_form
      @degrees = application_form.application_qualifications.degrees.order(id: :desc)
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
        naric_statment_row(degree),
        naric_reference_row(degree),
        comparable_uk_degree_row(degree),
        completion_status_row(degree),
        grade_row(degree),
        start_year_row(degree),
        award_year_row(degree),
      ].compact
    end

    def show_missing_banner?
      @show_incomplete && !@application_form.degrees_completed && @editable
    end

    def title(degree)
      "#{degree_type_with_honours(degree)} #{degree.subject}"
    end

  private

    attr_reader :application_form

    def degree_type_with_honours(degree)
      if international?(degree)
        degree.qualification_type
      elsif degree.grade&.include? 'honours'
        "#{abbreviate_degree(degree.qualification_type)} (Hons)"
      else
        abbreviate_degree(degree.qualification_type)
      end
    end

    def abbreviate_degree(name)
      Hesa::DegreeType.find_by_name(name)&.abbreviation || name
    end

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
        value: institution_value(degree),
        action: generate_action(degree: degree, attribute: t('application_form.degree.institution_name.change_action')),
        change_path: Rails.application.routes.url_helpers.candidate_interface_edit_degree_institution_path(degree.id),
      }
    end

    def institution_value(degree)
      if international?(degree) && degree.institution_country.present?
        "#{degree.institution_name}, #{COUNTRIES[degree.institution_country]}"
      else
        degree.institution_name
      end
    end

    def international?(degree)
      degree.international?
    end

    def naric_statment_row(degree)
      return nil unless international?(degree)

      {
        key: t('application_form.degree.naric_statment.review_label'),
        value: degree.naric_reference.present? ? 'Yes' : 'No',
        action: generate_action(degree: degree, attribute: t('application_form.degree.naric_statment.change_action')),
        change_path: Rails.application.routes.url_helpers.candidate_interface_edit_degree_naric_path(degree.id),
      }
    end

    def naric_reference_row(degree)
      return nil unless international?(degree) && degree.naric_reference.present?

      {
        key: t('application_form.degree.naric_reference.review_label'),
        value: degree.naric_reference,
        action: generate_action(degree: degree, attribute: t('application_form.degree.naric_reference.change_action')),
        change_path: Rails.application.routes.url_helpers.candidate_interface_edit_degree_naric_path(degree.id),
      }
    end

    def comparable_uk_degree_row(degree)
      return nil unless international?(degree) && degree.naric_reference.present?

      {
        key: t('application_form.degree.comparable_uk_degree.review_label'),
        value: t("application_form.degree.comparable_uk_degree.values.#{degree.comparable_uk_degree}", default: ''),
        action: generate_action(degree: degree, attribute: t('application_form.degree.comparable_uk_degree.change_action')),
        change_path: Rails.application.routes.url_helpers.candidate_interface_edit_degree_naric_path(degree.id),
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
        key: degree.completed? ? t('application_form.degree.grade.review_label') : t('application_form.degree.grade.review_label_predicted'),
        value: degree.grade,
        action: generate_action(degree: degree, attribute: t('application_form.degree.grade.change_action')),
        change_path: Rails.application.routes.url_helpers.candidate_interface_edit_degree_grade_path(degree.id),
      }
    end

    def completion_status_row(degree)
      {
        key: t('application_form.degree.completion_status.review_label'),
        value: formatted_completion_status(degree),
        action: generate_action(degree: degree, attribute: t('application_form.degree.completion_status.change_action')),
        change_path: Rails.application.routes.url_helpers.candidate_interface_edit_degree_completion_status_path(degree.id),
      }
    end

    def formatted_completion_status(degree)
      degree.completed? ? 'Yes' : 'No'
    end

    def generate_action(degree:, attribute: '')
      "#{attribute.presence} for #{degree.qualification_type}, #{degree.subject}, #{degree.institution_name}, #{degree.award_year}"
    end
  end
end
