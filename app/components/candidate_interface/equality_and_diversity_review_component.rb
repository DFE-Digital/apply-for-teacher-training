module CandidateInterface
  class EqualityAndDiversityReviewComponent < ViewComponent::Base
    def initialize(application_form:, editable: true, missing_error: false, submitting_application: false, return_to_application_review: false)
      @application_form = application_form
      @editable = editable
      @missing_error = missing_error
      @submitting_application = submitting_application
      @return_to_application_review = return_to_application_review
    end

    def equality_and_diversity_rows
      [sex_row, disabilities_row, ethnicity_row, free_school_meals_row].compact
    end

    def show_missing_banner?
      !@application_form.equality_and_diversity_completed && @editable if @submitting_application
    end

  private

    def incomplete_component_redirect_path
      if @application_form.equality_and_diversity_answers_provided?
        candidate_interface_review_equality_and_diversity_path
      else
        candidate_interface_edit_equality_and_diversity_sex_path
      end
    end

    def sex_row
      {
        key: 'Sex',
        value: @application_form.equality_and_diversity['sex'].capitalize,
        action: {
          href: candidate_interface_edit_equality_and_diversity_sex_path(return_to_params),
          visually_hidden_text: 'sex',
        },
      }
    end

    def disabilities_row
      disabilties = if @application_form.equality_and_diversity['disabilities'].include?(I18n.t('equality_and_diversity.disabilities.no.label')) || @application_form.equality_and_diversity['disabilities'].blank?
                      'I do not have any of these disabilities or health conditions'
                    elsif @application_form.equality_and_diversity['disabilities'].include?(I18n.t('equality_and_diversity.disabilities.opt_out.label'))
                      'Prefer not to say'
                    else
                      @application_form.equality_and_diversity['disabilities']
                    end

      {
        key: 'Disabilities or health conditions',
        value: disabilties,
        action: {
          href: candidate_interface_edit_equality_and_diversity_disabilities_path(return_to_params),
          visually_hidden_text: 'disability',
        },
      }
    end

    def ethnicity_row
      ethnicity = if @application_form.equality_and_diversity['ethnic_group'] == 'Prefer not to say'
                    'Prefer not to say'
                  elsif @application_form.equality_and_diversity['ethnic_background'] == 'Prefer not to say'
                    @application_form.equality_and_diversity['ethnic_group']
                  else
                    @application_form.equality_and_diversity['ethnic_background'].to_s
                  end

      {
        key: 'Ethnicity',
        value: ethnicity,
        action: {
          href: candidate_interface_edit_equality_and_diversity_ethnic_group_path(return_to_params),
          visually_hidden_text: 'ethnicity',
        },
      }
    end

    def free_school_meals_row
      return if not_answered_free_school_meals?

      free_school_meals = if @application_form.equality_and_diversity['free_school_meals'] == 'no'
                            t('equality_and_diversity.free_school_meals.no.review_value')
                          elsif @application_form.equality_and_diversity['free_school_meals'] == 'yes'
                            t('equality_and_diversity.free_school_meals.yes.review_value')
                          elsif @application_form.equality_and_diversity['free_school_meals'] == 'I do not know'
                            t('equality_and_diversity.free_school_meals.unknown.review_value')
                          else
                            @application_form.equality_and_diversity['free_school_meals']
                          end
      {
        key: 'Free school meals',
        value: free_school_meals,
        action: {
          href: candidate_interface_edit_equality_and_diversity_free_school_meals_path(return_to_params),
          visually_hidden_text: 'whether you ever got free school meals',
        },
      }
    end

    def not_answered_free_school_meals?
      @application_form.equality_and_diversity['free_school_meals'].nil?
    end

    def return_to_params
      if @return_to_application_review
        { return_to: 'application-review' }
      else
        { return_to: 'review' }
      end
    end
  end
end
