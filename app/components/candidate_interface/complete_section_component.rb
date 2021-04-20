module CandidateInterface
  class CompleteSectionComponent < ViewComponent::Base
    attr_reader :section_complete_form, :path, :request_method, :summary_component, :section_review

    def initialize(section_complete_form:, path:, request_method:, summary_component:, section_review: false)
      @section_complete_form = section_complete_form
      @path = path
      @request_method = request_method
      @summary_component = summary_component
      @section_review = section_review
    end

    def radio_button_label
      if section_review
        'application_form.reviewed_radio'
      else
        'application_form.completed_radio'
      end
    end
  end
end
