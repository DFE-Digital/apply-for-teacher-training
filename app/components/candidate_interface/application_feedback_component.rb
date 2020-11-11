module CandidateInterface
  class ApplicationFeedbackComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :section, :path, :page_title

    def initialize(section:, path:, page_title:)
      @section = section
      @path = path
      @page_title = page_title
    end
  end
end
