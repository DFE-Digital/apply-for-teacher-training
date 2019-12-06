module ApiDocs
  class ReferenceController < ApiDocsController
    def reference
      @document = Openapi3Parser.load_file('config/vendor-api-0.8.0.yml')
    end
  end
end
