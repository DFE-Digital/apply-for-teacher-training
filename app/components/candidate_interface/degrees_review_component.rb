module CandidateInterface
  class DegreesReviewComponent < ViewComponent::Base
    include ViewHelper

    def initialize(application_form:, editable: true, heading_level: 2, show_incomplete: false, missing_error: false, return_to_application_review: false)
      @application_form = application_form
      @degrees = application_form.application_qualifications.degrees.order(id: :desc)
      @editable = editable
      @heading_level = heading_level
      @show_incomplete = show_incomplete
      @missing_error = missing_error
      @return_to_application_review = return_to_application_review
    end

    def degree_rows(degree)
      [
        degree_type_row(degree),
        subject_row(degree),
        institution_row(degree),
        enic_statement_row(degree),
        enic_reference_row(degree),
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
        action: {
          href: candidate_interface_edit_degree_type_path(degree.id, return_to_params),
          visually_hidden_text: generate_action(degree:, attribute: t('application_form.degree.qualification.change_action')),
        },
        html_attributes: {
          data: {
            qa: 'degree-type',
          },
        },
      }
    end

    def subject_row(degree)
      {
        key: t('application_form.degree.subject.review_label'),
        value: degree.subject,
        action: {
          href: candidate_interface_edit_degree_subject_path(degree.id, return_to_params),
          visually_hidden_text: generate_action(degree:, attribute: t('application_form.degree.subject.change_action')),
        },
        html_attributes: {
          data: {
            qa: 'degree-subject',
          },
        },
      }
    end

    def institution_row(degree)
      {
        key: t('application_form.degree.institution_name.review_label'),
        value: institution_value(degree).to_s,
        action: {
          href: candidate_interface_edit_degree_institution_path(degree.id, return_to_params),
          visually_hidden_text: generate_action(degree:, attribute: t('application_form.degree.institution_name.change_action')),
        },
        html_attributes: {
          data: {
            qa: 'degree-institution',
          },
        },
      }
    end

    def institution_value(degree)
      if international?(degree) && degree.institution_country.present?
        "#{degree.institution_name}, #{COUNTRIES_AND_TERRITORIES[degree.institution_country]}"
      else
        degree.institution_name
      end
    end

    def international?(degree)
      degree.international?
    end

    def enic_statement_row(degree)
      return nil unless international?(degree)

      {
        key: t('application_form.degree.enic_statement.review_label'),
        value: degree.enic_reference.present? ? 'Yes' : 'No',
        action: {
          href: candidate_interface_edit_degree_enic_path(degree.id, return_to_params),
          visually_hidden_text: generate_action(degree:, attribute: t('application_form.degree.enic_statement.change_action')),
        },
        html_attributes: {
          data: {
            qa: 'degree-enic-comparability',
          },
        },
      }
    end

    def enic_reference_row(degree)
      return nil unless international?(degree) && degree.enic_reference.present?

      {
        key: t('application_form.degree.enic_reference.review_label'),
        value: degree.enic_reference,
        action: {
          href: candidate_interface_edit_degree_enic_path(degree.id, return_to_params),
          visually_hidden_text: generate_action(degree:, attribute: t('application_form.degree.enic_reference.change_action')),
        },
        html_attributes: {
          data: {
            qa: 'degree-enic-reference',
          },
        },
      }
    end

    def comparable_uk_degree_row(degree)
      return nil unless international?(degree) && degree.enic_reference.present?

      {
        key: t('application_form.degree.comparable_uk_degree.review_label'),
        value: t("application_form.degree.comparable_uk_degree.values.#{degree.comparable_uk_degree}", default: ''),
        action: {
          href: candidate_interface_edit_degree_enic_path(degree.id, return_to_params),
          visually_hidden_text: generate_action(degree:, attribute: t('application_form.degree.comparable_uk_degree.change_action')),
        },
        html_attributes: {
          data: {
            qa: 'degree-comparable-uk-degree',
          },
        },
      }
    end

    def start_year_row(degree)
      {
        key: t('application_form.degree.start_year.review_label'),
        value: degree.start_year,
        action: {
          href: candidate_interface_edit_degree_start_year_path(degree.id, return_to_params),
          visually_hidden_text: generate_action(degree:, attribute: t('application_form.degree.start_year.change_action')),
        },
        html_attributes: {
          data: {
            qa: 'degree-start-year',
          },
        },
      }
    end

    def award_year_row(degree)
      {
        key: t('application_form.degree.award_year.review_label'),
        value: degree.award_year || t('application_form.degree.review.not_specified'),
        action: {
          href: candidate_interface_edit_degree_award_year_path(degree.id, return_to_params),
          visually_hidden_text: generate_action(degree:, attribute: t('application_form.degree.award_year.change_action')),
        },
        html_attributes: {
          data: {
            qa: 'degree-award-year',
          },
        },
      }
    end

    def grade_row(degree)
      {
        key: degree.completed? ? t('application_form.degree.grade.review_label') : t('application_form.degree.grade.review_label_predicted'),
        value: degree.grade || t('application_form.degree.review.not_specified'),
        action: {
          href: candidate_interface_edit_degree_grade_path(degree.id, return_to_params),
          visually_hidden_text: generate_action(degree:, attribute: t('application_form.degree.grade.change_action')),
        },
        html_attributes: {
          data: {
            qa: 'degree-grade',
          },
        },
      }
    end

    def completion_status_row(degree)
      {
        key: t('application_form.degree.completion_status.review_label'),
        value: formatted_completion_status(degree),
        action: {
          href: candidate_interface_edit_degree_completion_status_path(degree.id, return_to_params),
          visually_hidden_text: generate_action(degree:, attribute: t('application_form.degree.completion_status.change_action')),
        },
        html_attributes: {
          data: {
            qa: 'degree-completion-status',
          },
        },
      }
    end

    def formatted_completion_status(degree)
      return if degree.predicted_grade.nil?

      degree.completed? ? 'Yes' : 'No'
    end

    def generate_action(degree:, attribute: '')
      "#{attribute.presence} for #{degree.qualification_type}, #{degree.subject}, #{degree.institution_name}, #{degree.award_year}"
    end

    def return_to_params
      { 'return-to' => 'application-review' } if @return_to_application_review
    end
  end
end
