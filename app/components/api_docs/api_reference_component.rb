module APIDocs
  class APIReferenceComponent < ViewComponent::Base
    def initialize(api_reference)
      @api_reference = api_reference
    end
  end
end
