module ProviderInterface
  class SafeguardingDeclarationComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_choice, :current_provider_user

    def initialize(application_choice:, current_provider_user:)
      @application_choice = application_choice
      @current_provider_user = current_provider_user
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

    def provider_user_associated_with_training_provider?
      current_provider_user.providers.include? application_choice.offered_course.provider
    end

    def fix_it_yourself_path
      return unless provider_user_associated_with_training_provider?

      training_provider = application_choice.offered_course.provider

      if training_provider.provider_permissions.exists?(
        provider_user: current_provider_user,
        view_safeguarding_information: true,
        manage_organisations: true,
      )
        relationship = ProviderRelationshipPermissions.find_by(
          training_provider: training_provider,
          ratifying_provider: application_choice.offered_course.accredited_provider,
        )

        url_helpers.provider_interface_edit_provider_relationship_permissions_path(id: relationship.id) if relationship
      elsif training_provider.provider_permissions.exists?(
        provider_user: current_provider_user,
        view_safeguarding_information: false,
        manage_users: true,
      )
        url_helpers.provider_interface_edit_permissions_path(
          provider_user_id: current_provider_user.id,
          provider_id: training_provider.id,
        )
      end
    end

    def training_provider_user_who_can_fix_this
      training_provider = application_choice.offered_course.provider

      if training_provider.provider_permissions.exists?(
        provider_user: current_provider_user,
        view_safeguarding_information: true,
      )
        application_choice.offered_course.provider.provider_permissions.find_by(manage_organisations: true)&.provider_user
      else
        application_choice.offered_course.provider.provider_permissions.find_by(manage_users: true)&.provider_user
      end
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
      current_provider_user.authorisation
        .can_view_safeguarding_information?(course: application_choice.course)
    end

    def safeguarding_issues_declared?
      application_choice.application_form.has_safeguarding_issues_to_declare?
    end

    def url_helpers
      Rails.application.routes.url_helpers
    end
  end
end
