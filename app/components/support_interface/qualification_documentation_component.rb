module SupportInterface
  class QualificationDocumentationComponent < ViewComponent::Base
    attr_reader :list

    def initialize(list:)
      @list = list
    end
  end
end
