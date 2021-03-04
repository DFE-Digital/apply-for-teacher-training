module APIDocs
  class PropertyListComponent < ViewComponent::Base
    include APIDocsHelper
    include ViewHelper
    include MarkdownHelper

    attr_reader :properties

    def initialize(properties)
      @properties = properties
    end
  end
end
