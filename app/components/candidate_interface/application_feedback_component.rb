module CandidateInterface
  class ApplicationFeedbackComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :path, :page_title

    def initialize(path:, page_title:)
      @path = path
      @page_title = page_title
    end
  end
end
