module ProviderInterface
  class SafeguardingDeclarationComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :safeguarding_status

    def initialize(application_form:)
      @safeguarding_status = SafeguardingStatus.new(
        application_form: application_form,
        i18n_key: 'provider_interface.safeguarding_declaration_component',
      )
    end

    def message
      safeguarding_status.message
    end
  end
end
