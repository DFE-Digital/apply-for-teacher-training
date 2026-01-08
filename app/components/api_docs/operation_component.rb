module APIDocs
  class OperationComponent < BaseComponent
    include MarkdownHelper
    include ViewHelper
    include APIDocsHelper

    attr_reader :operation

    def initialize(operation)
      @operation = operation
    end
  end
end
