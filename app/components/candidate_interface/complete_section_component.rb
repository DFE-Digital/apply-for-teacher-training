module CandidateInterface
  class CompleteSectionComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :section_policy, :form, :hint_text, :section_review

    def initialize(section_policy:, form:, section_review: false, hint_text: false)
      @section_policy = section_policy
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

    def submitted_applications?
      helpers.current_application.submitted_applications?
    end
  end
end
