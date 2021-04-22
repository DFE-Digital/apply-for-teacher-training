module CandidateInterface
  class CompleteSectionComponent < ViewComponent::Base
    attr_reader :section_complete_form, :path, :request_method, :summary_component, :complete_hint_text, :section_review

    def initialize(section_complete_form:, path:, request_method:, summary_component: nil, section_review: false, complete_hint_text: false)
      @section_complete_form = section_complete_form
      @path = path
      @request_method = request_method
      @summary_component = summary_component
      @section_review = section_review
      @complete_hint_text = complete_hint_text
    end

    def radio_button_label
      if section_review
        t('application_form.reviewed_radio')
      else
        t('application_form.completed_radio')
      end
    end
  end
end
