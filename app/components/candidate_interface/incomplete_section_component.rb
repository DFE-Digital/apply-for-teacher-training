module CandidateInterface
  class IncompleteSectionComponent < ViewComponent::Base
    include ViewHelper

    def initialize(
      section:,
      section_path:,
      text: t("review_application.#{section}.incomplete"),
      link_text: t("review_application.#{section}.complete_section"),
      error: false
    )
      @section = section
      @section_path = section_path
      @text = text
      @error = error
      @link_text = link_text
    end

    attr_reader :section, :section_path, :text, :link_text
  end
end
