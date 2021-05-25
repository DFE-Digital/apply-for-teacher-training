module CandidateInterface
  class Reference::SelectionForm
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    attr_accessor :application_form, :selected

    before_validation :clean_up_checkbox_params
    validate :correct_number_chosen?

    def available_references
      application_form.application_references.feedback_provided
    end

    def save!
      return false unless valid?

      available_references.where.not(id: selected).update_all(selected: false)
      available_references.where(id: selected).update_all(selected: true)
      application_form.update!(references_completed: true)
    end

  private

    def clean_up_checkbox_params
      self.selected = selected.reject(&:blank?)
    end

    def correct_number_chosen?
      required = ApplicationForm::MINIMUM_COMPLETE_REFERENCES
      if selected.size < required || selected.size > required
        errors.add(:selected, "Select #{required} references")
      end
    end
  end
end
