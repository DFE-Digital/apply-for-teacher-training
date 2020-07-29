module ProviderInterface
  class UserDetailsOrganisationsList < ViewComponent::Base
    include ViewHelper

    def initialize(organisations)
      @organisations = organisations
    end
  end
end
