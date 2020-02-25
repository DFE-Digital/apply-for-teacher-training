module CandidateInterface
  class EqualityAndDiversityReviewComponent < ActionView::Component::Base
    def initialize(application_form:, editable: true)
      @application_form = application_form
      @editable = editable
    end

    def equality_and_diversity_rows
      [sex_row, disabilities_row]
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
  end
end
