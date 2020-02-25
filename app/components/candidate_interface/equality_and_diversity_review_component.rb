module CandidateInterface
  class EqualityAndDiversityReviewComponent < ActionView::Component::Base
    def initialize(application_form:, editable: true)
      @application_form = application_form
      @editable = editable
    end

    def equality_and_diversity_rows
      [sex_row]
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
  end
end
