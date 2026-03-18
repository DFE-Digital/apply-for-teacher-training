module SupportInterface
  class QualificationDocumentationComponent < ApplicationComponent
    attr_reader :list

    def initialize(list:)
      @list = list
    end
  end
end
