module CandidateInterface
  class EqualityAndDiversityReviewComponent < ViewComponent::Base
    def initialize(application_form:, editable: true)
      @application_form = application_form
      @editable = editable
    end

    def equality_and_diversity_rows
      [sex_row, disabilities_row, ethnicity_row]
    end

  private

    def sex_row
      {
        key: 'Sex',
        value: @application_form.equality_and_diversity['sex'].capitalize,
        action: 'sex',
        change_path: candidate_interface_edit_equality_and_diversity_sex_path,
      }
    end

    def disabilities_row
      disabilties = if @application_form.equality_and_diversity['disabilities'].empty?
                      'No'
                    elsif @application_form.equality_and_diversity['disabilities'].include?('Prefer not to say')
                      'Prefer not to say'
                    else
                      "Yes (#{@application_form.equality_and_diversity['disabilities'].to_sentence(last_word_connector: ' and ')})"
                    end

      {
        key: 'Disability',
        value: disabilties,
        action: 'disability',
        change_path: candidate_interface_edit_equality_and_diversity_disability_status_path,
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
        action: 'ethnicity',
        change_path: candidate_interface_edit_equality_and_diversity_ethnic_group_path,
      }
    end
  end
end
