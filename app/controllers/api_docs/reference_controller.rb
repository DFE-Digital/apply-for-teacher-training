module ApiDocs
  class ReferenceController < ApiDocsController
    def reference
      @api_reference = ApiReference.new
    end
  end
end
