module CandidateInterface
  class CompleteSectionComponent < ViewComponent::Base
    attr_reader :form, :hint_text, :section_review

    def initialize(form:, section_review: false, hint_text: false)
      @form = form
      @section_review = section_review
      @hint_text = hint_text
    end

    def complete_or_reviewed_radio_button_label
      if section_review
        t('application_form.reviewed_radio')
      else
        t('application_form.completed_radio')
      end
    end
  end
end
