module ProviderInterface
  class SafeguardingDeclarationComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_choice, :current_provider_user, :relationship

    def initialize(application_choice:, current_provider_user:)
      @application_choice = application_choice
      @current_provider_user = current_provider_user

      @auth = current_provider_user.authorisation
      @auth_result = @auth.can_view_safeguarding_information?(course: application_choice.course)
      @analysis = ProviderAuthorisationAnalysis.new(
        permission: :view_safeguarding_information,
        auth: @auth,
        application_choice: @application_choice,
      )
    end

    def message
      SafeguardingStatus.new(
        status: status,
        i18n_key: 'provider_interface.safeguarding_declaration_component',
      ).message
    end

    def display_safeguarding_issues_details?
      safeguarding_issues_declared? && current_user_has_permission_to_view_safeguarding_information?
    end

    def details
      application_choice.application_form.safeguarding_issues
    end

  private

    def status
      if safeguarding_issues_declared? && !current_user_has_permission_to_view_safeguarding_information?
        'has_safeguarding_issues_to_declare_no_permissions'
      else
        application_choice.application_form.safeguarding_issues_status
      end
    end

    def current_user_has_permission_to_view_safeguarding_information?
      @auth_result
    end

    def safeguarding_issues_declared?
      application_choice.application_form.has_safeguarding_issues_to_declare?
    end
  end
end
