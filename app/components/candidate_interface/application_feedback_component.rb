module CandidateInterface
  class ApplicationFeedbackComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :path, :page_title

    def initialize(path:, page_title:)
      @path = path
      @page_title = page_title
    end

    def section
      case
      when @path.include?('candidate/application/references')
        'references'
      when @path.include?('candidate/application/degrees')
        'qualifications'
      when @path.include?('candidate/application/gcse')
        'qualifications'
      when @path.include?('candidate/application/other-qualifications')
        'qualifications'
      when @path.include?('candidate/application/personal-statement')
        'personal statement and interview'
      else
        raise "You need to define a section name for pages that include #{@path}"
      end
    end
  end
end
