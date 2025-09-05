module CandidateInterface
  class InvalidSectionComponent < ApplicationComponent
    include ViewHelper

    def before_render
      @text = t("review_application.#{section}.invalid")
      @link_text = t("review_application.#{section}.complete_section")
    end

    def initialize(
      section:,
      section_path:,
      error: false,
      review_needed: false,
      text: nil,
      link_text: nil
    )
      @section = section
      @section_path = section_path
      @error = error
      @review_needed = review_needed
      @text ||= text
      @link_text ||= link_text
    end

    attr_reader :section, :section_path, :text, :link_text

    def message
      text
    end
  end
end
