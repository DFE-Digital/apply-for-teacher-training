module CandidateInterface
  class IncompleteSectionComponent < ViewComponent::Base
    include ViewHelper

    def initialize(
      section:,
      section_path:,
      text: t("review_application.#{section}.incomplete"),
      link_text: t("review_application.#{section}.complete_section"),
      error: false,
      review_needed: false
    )
      @section = section
      @section_path = section_path
      @text = text
      @error = error
      @link_text = link_text
      @review_needed = review_needed
    end

    attr_reader :section, :section_path, :text, :link_text

    def message
      if @review_needed
        t("review_application.#{section}.not_reviewed")
      else
        text
      end
    end
  end
end
