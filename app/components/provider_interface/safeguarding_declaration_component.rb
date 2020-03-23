module ProviderInterface
  class SafeguardingDeclarationComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def has_disclosed_safeguarding_issues?
      @application_form.safeguarding_issues.eql?('Yes') ? true : false
    end
  end
end
