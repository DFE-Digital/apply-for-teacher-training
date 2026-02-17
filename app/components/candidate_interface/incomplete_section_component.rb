module CandidateInterface
  class IncompleteSectionComponent < ApplicationComponent
    include ViewHelper

    def before_render
      @text = t("review_application.#{section}.incomplete")
      @link_text = t("review_application.#{section}.complete_section")
    end

    def initialize(
      section:,
      section_path:,
      text: nil,
      link_text: nil,
      error: false,
      review_needed: false
    )
      @section = section
      @section_path = section_path
      @text ||= text
      @error = error
      @link_text ||= link_text
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
