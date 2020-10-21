module ProviderInterface
  class SafeguardingDeclarationComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_choice, :current_provider_user, :relationship

    def initialize(application_choice:, current_provider_user:)
      @application_choice = application_choice
      @current_provider_user = current_provider_user

      @auth = current_provider_user.authorisation
      @auth_result = @auth.can_view_safeguarding_information?(course: application_choice.course)

      @training_provider = application_choice.offered_course.provider
      @ratifying_provider = application_choice.offered_course.accredited_provider

      @relationship = ProviderRelationshipPermissions.find_by(
        training_provider: @training_provider,
        ratifying_provider: @ratifying_provider,
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

    def provider_user_associated_with_training_provider?
      @_is_training_provider_user ||= current_provider_user.providers.include?(application_choice.offered_course.provider)
    end

    def provider_relationship_has_been_set_up?
      return true if @ratifying_provider.blank?

      relationship.setup_at.present? if relationship
    end

    def provider_relationship_allows_access?
      if provider_user_associated_with_training_provider?
        !@auth.errors.include?(:requires_training_provider_permission)
      else
        !@auth.errors.include?(:requires_ratifying_provider_permission)
      end
    end

    def provider_user_has_user_level_access?
      !@auth.errors.include?(:requires_provider_user_permission)
    end

    def provider_user_can_manage_users?
      if provider_user_associated_with_training_provider?
        @auth.can_manage_users_for? @training_provider
      else
        @auth.can_manage_users_for? @ratifying_provider
      end
    end

    def provider_user_can_manage_organisations?
      if provider_user_associated_with_training_provider?
        @auth.can_manage_organisation? provider: @training_provider
      else
        @auth.can_manage_organisation? provider: @ratifying_provider
      end
    end

    def other_provider_users_who_can_manage_users
      @_alt_manage_users ||= if provider_user_associated_with_training_provider?
                               @training_provider.provider_permissions.manage_users.where.not(
                                 provider_user: current_provider_user,
                               ).map(&:provider_user)
                             else
                               @ratifying_provider.provider_permissions.manage_users.where.not(
                                 provider_user: current_provider_user,
                               ).map(&:provider_user)
                             end
    end

    def other_provider_users_who_can_manage_organisations
      @_alt_manage_orgs ||= if provider_user_associated_with_training_provider?
                              @training_provider.provider_permissions.manage_organisations.where.not(
                                provider_user: current_provider_user,
                              ).map(&:provider_user)
                            else
                              @ratifying_provider.provider_permissions.manage_organisations.where.not(
                                provider_user: current_provider_user,
                              ).map(&:provider_user)
                            end
    end

    def fix_user_permissions_path
      if provider_user_associated_with_training_provider?
        url_helpers.provider_interface_provider_user_edit_permissions_path(
          provider_id: @training_provider.id,
          provider_user_id: current_provider_user.id,
        )
      else
        url_helpers.provider_interface_provider_user_edit_permissions_path(
          provider_id: @ratifying_provider.id,
          provider_user_id: current_provider_user.id,
        )
      end
    end

    def fix_org_permissions_path
      url_helpers.provider_interface_edit_provider_relationship_permissions_path(id: relationship.id) if relationship
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

    def url_helpers
      Rails.application.routes.url_helpers
    end
  end
end
