class ProviderAuthorisationAnalysis
  attr_reader :permission, :auth, :application_choice,
              :training_provider, :ratifying_provider, :relationship

  # This class is meant to be used after an auth call has already been performed
  def initialize(permission:, auth:, application_choice:, course_option_id: nil)
    @permission = permission
    @auth = auth
    @application_choice = application_choice
    @course_option_id = course_option_id
    @course_option_id ||= @application_choice.offered_option.id

    @training_provider = application_choice.offered_course.provider
    @ratifying_provider = application_choice.offered_course.accredited_provider

    @relationship = ProviderRelationshipPermissions.find_by(
      training_provider: @training_provider,
      ratifying_provider: @ratifying_provider,
    )
  end

  def course
    @_course ||= CourseOption.find(@course_option_id).course
  end

  def provider_user
    auth.actor
  end

  def ratified_course?
    ratifying_provider.present?
  end

  def provider_user_associated_with_training_provider?
    @_is_training_provider_user ||= provider_user.providers.include?(application_choice.offered_course.provider)
  end

  def provider_relationship_has_been_set_up?
    return true if ratifying_provider.blank?

    relationship.setup_at.present? if relationship
  end

  def provider_relationship_allows_access?
    valid_relationship_present = !auth.errors.include?(:requires_training_or_ratifying_provider_permission)

    if provider_user_associated_with_training_provider?
      valid_relationship_present && !auth.errors.include?(:requires_training_provider_permission)
    else
      valid_relationship_present && !auth.errors.include?(:requires_ratifying_provider_permission)
    end
  end

  def provider_user_has_user_level_access?
    !auth.errors.include?(:requires_provider_user_permission)
  end

  def provider_user_can_manage_users?
    if provider_user_associated_with_training_provider?
      auth.can_manage_users_for? provider: training_provider
    else
      auth.can_manage_users_for? provider: ratifying_provider
    end
  end

  def provider_user_can_manage_organisations?
    if provider_user_associated_with_training_provider?
      auth.can_manage_organisation? provider: training_provider
    else
      auth.can_manage_organisation? provider: ratifying_provider
    end
  end

  def other_provider_users_who_can_manage_users
    @_alt_manage_users ||= if provider_user_associated_with_training_provider?
                             training_provider.provider_permissions.manage_users.where.not(
                               provider_user: provider_user,
                             ).map(&:provider_user)
                           else
                             ratifying_provider.provider_permissions.manage_users.where.not(
                               provider_user: provider_user,
                             ).map(&:provider_user)
                           end
  end

  def other_provider_users_who_can_manage_organisations
    @_alt_manage_orgs ||= if provider_user_associated_with_training_provider?
                            training_provider.provider_permissions.manage_organisations.where.not(
                              provider_user: provider_user,
                            ).map(&:provider_user)
                          else
                            ratifying_provider.provider_permissions.manage_organisations.where.not(
                              provider_user: provider_user,
                            ).map(&:provider_user)
                          end
  end

  def training_provider_users_who_can_manage_organisations
    @_training_provider_users_manage_orgs ||=
      training_provider.provider_permissions.manage_organisations.map(&:provider_user)
  end

  def fix_user_permissions_path
    if provider_user_associated_with_training_provider?
      url_helpers.provider_interface_provider_user_edit_permissions_path(
        provider_id: training_provider.id,
        provider_user_id: provider_user.id,
      )
    else
      url_helpers.provider_interface_provider_user_edit_permissions_path(
        provider_id: ratifying_provider.id,
        provider_user_id: provider_user.id,
      )
    end
  end

  def fix_org_permissions_path
    url_helpers.provider_interface_edit_provider_relationship_permissions_path(id: relationship.id) if relationship
  end

private

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
