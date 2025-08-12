module CandidateInterface
  class DegreeReviewComponent < ViewComponent::Base
    include ViewHelper
    include EnicReasonTranslationHelper

    def initialize(application_form:, editable: true, heading_level: 2, show_incomplete: false, missing_error: false, return_to_application_review: false, deletable: true)
      @application_form = application_form
      @degrees = application_form.application_qualifications.degrees.order(id: :desc)
      @editable = editable
      @heading_level = heading_level
      @show_incomplete = show_incomplete
      @missing_error = missing_error
      @return_to_application_review = return_to_application_review
      @deletable = deletable
    end

    def degree_rows(degree)
      [
        country_row(degree),
        degree_type_row(degree),
        type_of_uk_degree(degree),
        subject_row(degree),
        institution_row(degree),
        completion_status_row(degree),
        grade_row(degree),
        start_year_row(degree),
        award_year_row(degree),
        enic_statement_row(degree),
        enic_reference_row(degree),
        comparable_uk_degree_row(degree),
      ].compact
    end

    def show_missing_banner?
      @show_incomplete && !@application_form.degrees_completed && @editable
    end

    def title(degree)
      "#{degree_type_with_honours(degree)} #{degree.subject}"
    end

    def deletable?
      @editable && @deletable
    end

  private

    attr_reader :application_form

    def degree_type_with_honours(degree)
      if degree.international?
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

    def country_row(degree)
      {
        key: t('application_form.degree.institution_country.review_label'),
        value: COUNTRIES_AND_TERRITORIES[degree.institution_country],
        action: {
          href: candidate_interface_degree_edit_path(degree.id, :country),
          visually_hidden_text: generate_action(degree:, attribute: t('application_form.degree.institution_country.change_action')),
        },
        html_attributes: {
          data: {
            qa: 'degree-country',
          },
        },
      }
    end

    def degree_type_row(degree)
      {
        key: t('application_form.degree.qualification_type.review_label'),
        value: formatted_degree_type(degree) || degree.qualification_type,
        action: {
          href: candidate_interface_degree_edit_path(degree.id, uk_or_compatible_degree?(degree) ? 'degree_level' : 'type'),
          visually_hidden_text: generate_action(degree:, attribute: t('application_form.degree.qualification.change_action')),
        },
        html_attributes: {
          data: {
            qa: 'degree-type',
          },
        },
      }
    end

    def type_of_uk_degree(degree)
      return unless uk_or_compatible_degree?(degree)
      return if formatted_degree_type(degree).nil?

      {
        key: t('application_form.degree.type_of_degree.review_label', degree: append_degree(degree).to_s.downcase),
        value: degree.qualification_type,
        action: {
          href: candidate_interface_degree_edit_path(degree.id, :type),
          visually_hidden_text: generate_action(degree:, attribute: t('application_form.degree.type_of_degree.change_action', degree: append_degree(degree).to_s.downcase)),
        },
        html_attributes: {
          data: {
            qa: 'uk-degree-type',
          },
        },
      }
    end

    def uk_or_compatible_degree?(degree)
      uk?(degree) || international_structured_degree_data?(degree)
    end

    def subject_row(degree)
      {
        key: t('application_form.degree.subject.review_label'),
        value: degree.subject,
        action: {
          href: candidate_interface_degree_edit_path(degree.id, :subject),
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
        value: degree.institution_name,
        action: {
          href: candidate_interface_degree_edit_path(degree.id, :university),
          visually_hidden_text: generate_action(degree:, attribute: t('application_form.degree.institution_name.change_action')),
        },
        html_attributes: {
          data: {
            qa: 'degree-institution',
          },
        },
      }
    end

    def enic_statement_row(degree)
      return nil unless degree.international?

      {
        key: t('application_form.degree.enic_statement.review_label'),
        value: translate_enic_reason(degree.enic_reason),
        action: {
          href: candidate_interface_degree_edit_path(degree.id, :enic),
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
      return nil unless degree.international? && degree.enic_reference.present?
      return nil if degree.predicted_grade

      {
        key: t('application_form.degree.enic_reference.review_label'),
        value: degree.enic_reference,
        action: {
          href: candidate_interface_degree_edit_path(degree.id, :enic_reference),
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
      return nil unless degree.international? && degree.comparable_uk_degree.present?
      return nil if degree.predicted_grade

      {
        key: t('application_form.degree.comparable_uk_degree.review_label'),
        value: t("application_form.degree.comparable_uk_degree.values.#{degree.comparable_uk_degree}", default: ''),
        action: {
          href: candidate_interface_degree_edit_path(degree.id, :enic_reference),
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
          href: candidate_interface_degree_edit_path(degree.id, :start_year),
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
          href: candidate_interface_degree_edit_path(degree.id, :award_year),
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
      return nil if doctorate?(degree) && uk?(degree)

      {
        key: degree.completed? ? t('application_form.degree.grade.review_label') : t('application_form.degree.grade.review_label_predicted'),
        value: degree.grade || t('application_form.degree.review.not_specified'),
        action: {
          href: candidate_interface_degree_edit_path(degree.id, :grade),
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
          href: candidate_interface_degree_edit_path(degree.id, :completed),
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

    def formatted_degree_type(degree)
      return if degree.qualification_type.nil?

      if degree.qualification_level.in?(Degrees::FormConstants::QUALIFICATION_LEVEL)
        t(".#{degree.qualification_level}")
      else
        reference_data = DfE::ReferenceData::Degrees::TYPES.some_by_field(:name).keys.select { |type| degree.qualification_type.downcase == type.downcase }
        degree.qualification_type.split.first if reference_data.present?
      end
    end

    def append_degree(degree)
      if doctorate?(degree)
        'doctorate'
      elsif degree.qualification_level.present?
        formatted_degree_type(degree).to_s.downcase
      else
        "#{formatted_degree_type(degree)} degree"
      end
    end

    def doctorate?(degree)
      formatted_degree_type(degree) == 'Doctor' || degree.qualification_level == 'doctor'
    end

    def return_to_params
      { 'return-to' => 'application-review' } if @return_to_application_review
    end

    def international_structured_degree_data?(degree)
      degree.international_bachelors_degree_compatible_with_uk?
    end

    def uk?(degree)
      !degree.international?
    end
  end
end
