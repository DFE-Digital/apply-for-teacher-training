module ProviderInterface
  class SafeguardingDeclarationComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :message

    def initialize(application_form:)
      @message = SafeguardingStatus.new(
        status: application_form.safeguarding_issues_status,
        i18n_key: 'provider_interface.safeguarding_declaration_component',
      ).message
    end
  end
end
