module ProviderInterface
  class EditProviderUserPermissionsComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :permissions_form

    def initialize(form:)
      @permissions_form = form
    end
  end
end
