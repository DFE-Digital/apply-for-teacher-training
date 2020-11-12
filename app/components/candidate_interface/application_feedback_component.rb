module CandidateInterface
  class ApplicationFeedbackComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :section, :path, :page_title, :id_in_path

    def initialize(section:, path:, page_title:, id_in_path: nil)
      @section = section
      @path = path
      @page_title = page_title
      @id_in_path = id_in_path
    end
  end
end
