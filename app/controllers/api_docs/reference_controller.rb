module APIDocs
  class ReferenceController < APIDocsController
    def reference
      @api_reference = APIReference.new
    end
  end
end
