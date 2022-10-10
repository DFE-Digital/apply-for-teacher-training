module CandidateInterface
  class EqualityAndDiversityReviewComponent < ViewComponent::Base
    def initialize(application_form:, editable: true)
      @application_form = application_form
      @editable = editable
    end

    def equality_and_diversity_rows
      [sex_row, disabilities_row, ethnicity_row, free_school_meals_row].compact
    end

  private

    def sex_row
      {
        key: 'Sex',
        value: @application_form.equality_and_diversity['sex'].capitalize,
        action: {
          href: candidate_interface_edit_equality_and_diversity_sex_path,
          visually_hidden_text: 'sex',
        },
      }
    end

    def disabilities_row
      disabilties = if @application_form.equality_and_diversity['disabilities'].include?(I18n.t('equality_and_diversity.disabilities.no.label')) || @application_form.equality_and_diversity['disabilities'].blank?
                      'No'
                    elsif @application_form.equality_and_diversity['disabilities'].include?(I18n.t('equality_and_diversity.disabilities.opt_out.label'))
                      'Prefer not to say'
                    else
                      "Yes (#{@application_form.equality_and_diversity['disabilities'].to_sentence(last_word_connector: ' and ')})"
                    end

      {
        key: 'Disability',
        value: disabilties,
        action: {
          href: candidate_interface_edit_equality_and_diversity_disabilities_path,
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
                    "#{@application_form.equality_and_diversity['ethnic_group']} (#{@application_form.equality_and_diversity['ethnic_background']})"
                  end

      {
        key: 'Ethnicity',
        value: ethnicity,
        action: {
          href: candidate_interface_edit_equality_and_diversity_ethnic_group_path,
          visually_hidden_text: 'ethnicity',
        },
      }
    end

    def free_school_meals_row
      return if not_answered_free_school_meals?

      free_school_meals = if @application_form.equality_and_diversity['free_school_meals'] == 'no'
                            'I did not receive free school meals at any point during my school years'
                          elsif @application_form.equality_and_diversity['free_school_meals'] == 'yes'
                            'I received free school meals at some point during my school years'
                          elsif @application_form.equality_and_diversity['free_school_meals'] == 'I do not know'
                            'I do not know whether I received free school meals at any point during my school years'
                          else
                            @application_form.equality_and_diversity['free_school_meals']
                          end
      {
        key: 'Free school meals',
        value: free_school_meals,
        action: {
          href: candidate_interface_edit_equality_and_diversity_free_school_meals_path,
          visually_hidden_text: 'free school meals',
        },
      }
    end

    def not_answered_free_school_meals?
      @application_form.equality_and_diversity['free_school_meals'].nil?
    end
  end
end
