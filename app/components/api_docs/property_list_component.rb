module APIDocs
  class PropertyListComponent < ApplicationComponent
    include APIDocsHelper
    include ViewHelper
    include MarkdownHelper

    attr_reader :properties

    def initialize(properties)
      @properties = properties
    end
  end
end
