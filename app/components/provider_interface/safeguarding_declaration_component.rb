module ProviderInterface
  class SafeguardingDeclarationComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def message
      if has_no_answer?
        I18n.t('provider_interface.safeguarding_declaration_component.no_answer_message')
      elsif has_disclosed_safeguarding_issues?
        I18n.t('provider_interface.safeguarding_declaration_component.has_disclosed_message')
      else
        I18n.t('provider_interface.safeguarding_declaration_component.no_info_message')
      end
    end

  private

    def has_disclosed_safeguarding_issues?
      @application_form.safeguarding_issues != 'No'
    end

    def has_no_answer?
      @application_form.safeguarding_issues.blank?
    end
  end
end
