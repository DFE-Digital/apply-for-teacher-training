class ProviderInterface::FindCandidates::SafeguardingComponent < ApplicationComponent
  attr_reader :application_form, :provider_user

  def initialize(application_form:, provider_user:)
    @application_form = application_form
    @provider_user = provider_user
  end

  def rows
    rows = [{ key: I18n.t('provider_interface.safeguarding_declaration_component.declare_safeguarding_issues'), value: declare_safeguarding_issues }]

    if safeguarding_issues_declared?
      rows << { key: I18n.t('provider_interface.safeguarding_declaration_component.safeguarding_information'), value: safeguarding_information }
    end

    rows
  end

private

  def declare_safeguarding_issues
    if safeguarding_issues_declared?
      I18n.t('provider_interface.safeguarding_declaration_component.has_safeguarding_issues_to_declare')
    else
      I18n.t('provider_interface.safeguarding_declaration_component.no_safeguarding_issues_to_declare')
    end
  end

  def safeguarding_information
    if provider_user_can_view_safeguarding?
      application_form.safeguarding_issues
    else
      I18n.t('provider_interface.safeguarding_declaration_component.cannot_see_safeguarding_information')
    end
  end

  def provider_user_can_view_safeguarding?
    provider_user.provider_permissions.any?(&:view_safeguarding_information)
  end

  def safeguarding_issues_declared?
    application_form.has_safeguarding_issues_to_declare?
  end
end
