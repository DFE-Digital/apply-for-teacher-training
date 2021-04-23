module CandidateInterface
  class CompleteSectionComponent < ViewComponent::Base
    def initialize(application_form:, path:, request_method:, field_name:, section_review: false)
      @application_form = application_form
      @path = path
      @request_method = request_method
      @field_name = field_name
      @section_review = section_review
    end

    def checkbox_label
      if @section_review
        'application_form.reviewed_checkbox'
      else
        'application_form.completed_checkbox'
      end
    end
  end
end
