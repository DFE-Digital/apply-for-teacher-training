module SupportInterface
  class QualificationDocumentationComponent < BaseComponent
    attr_reader :list

    def initialize(list:)
      @list = list
    end
  end
end
