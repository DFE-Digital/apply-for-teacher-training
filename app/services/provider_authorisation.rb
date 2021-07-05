class ProviderAuthorisation
  attr_reader :actor

  def initialize(actor:)
    @actor = actor
    @errors = {}
  end

  # Queries/lookups ----------------------------------------------------------------
  def providers_that_actor_can_manage_users_for
    Provider.where(
      id: @actor.provider_permissions.where(manage_users: true).select(:provider_id),
    )
  end

  def can_manage_users_for_at_least_one_provider?
    ProviderPermissions.exists?(
      provider_user: @actor,
      manage_users: true,
    )
  end

  def provider_relationships_for_actor
    provider_ids = @actor.providers.pluck(:provider_id)

    table = ProviderRelationshipPermissions.arel_table
    member_of_training_provider = table[:training_provider_id].in(provider_ids)
    member_of_ratifying_provider = table[:ratifying_provider_id].in(provider_ids)

    ProviderRelationshipPermissions.where(
      member_of_training_provider.or(member_of_ratifying_provider),
    )
  end

  def providers_that_actor_can_manage_organisations_for(with_set_up_permissions: false)
    scope = provider_relationships_for_actor
    scope = scope.where.not(setup_at: nil) if with_set_up_permissions

    provider_ids = scope.pluck(:ratifying_provider_id, :training_provider_id).flatten
    manageable_providers_from(provider_ids)
  end

  def training_provider_relationships_that_actor_can_manage_organisations_for
    ProviderRelationshipPermissions
      .includes(:ratifying_provider, :training_provider)
      .joins("INNER JOIN #{ProviderPermissions.table_name} ON #{ProviderPermissions.table_name}.provider_id = provider_relationship_permissions.training_provider_id")
      .where(training_provider: @actor.providers)
      .where("#{ProviderPermissions.table_name}.provider_user_id": @actor.id, "#{ProviderPermissions.table_name}.manage_organisations": true)
      .order(:created_at)
  end

  def provider_relationships_that_actor_can_manage_organisations_for
    manageable_provider_ids = ProviderPermissions
      .where(provider_user: @actor, manage_organisations: true)
      .select(:provider_id)

    provider_relationships_for_actor
      .with(provider_ids: manageable_provider_ids)
      .joins('INNER JOIN provider_ids ON (training_provider_id = provider_id OR ratifying_provider_id = provider_id)')
  end

  # Authorisation -------------------------------------------------------------------
  def can_manage_users_for?(provider:)
    ProviderPermissions.exists?(
      provider: provider,
      provider_user: @actor,
      manage_users: true,
    )
  end

  def can_manage_organisation?(provider:)
    return true if @actor.is_a?(SupportUser)

    @actor.provider_permissions.exists?(provider: provider, manage_organisations: true)
  end

  def can_set_up_interviews?(provider:)
    return true if @actor.is_a?(SupportUser)

    ProviderPermissions.exists?(
      provider: provider,
      provider_user: @actor,
      set_up_interviews: true,
    )
  end

  def can_manage_organisations_for_at_least_one_provider?
    providers_that_actor_can_manage_organisations_for.any?
  end

  def can_manage_organisations_for_at_least_one_setup_provider?
    providers_that_actor_can_manage_organisations_for(with_set_up_permissions: true).any?
  end

  def can_view_safeguarding_information?(course:)
    full_authorisation? permission: :view_safeguarding_information, course: course
  end

  def can_view_diversity_information?(course:)
    full_authorisation? permission: :view_diversity_information, course: course
  end

  def can_make_decisions?(application_choice:, course_option_id: nil, course_option: nil)
    if course_option_id.blank? && course_option.blank?
      raise ValidationException, ['Please provide a course_option or course_option_id']
    end

    course_option_id ||= course_option.id
    course = CourseOption.find(course_option_id).course

    add_error(:make_decisions, :requires_application_choice_visibility) unless
      application_choice_visible_to_user?(application_choice: application_choice)

    add_error(:make_decisions, :requires_user_course_association) unless
      course_associated_with_user_providers?(course: course)

    full_authorisation? permission: :make_decisions, course: course

    errors.blank?
  end

  def assert_can_make_decisions!(application_choice:, course_option_id: nil, course_option: nil)
    if course_option_id.blank? && course_option.blank?
      raise ValidationException, ['Please provide a course_option or course_option_id']
    end

    course_option_id ||= course_option.id
    return if can_make_decisions?(application_choice: application_choice, course_option_id: course_option_id)

    raise NotAuthorisedError, full_error_messages.join(' ')
  end

  def errors
    @errors.values.flatten
  end

  class NotAuthorisedError < StandardError; end
  class RelationshipNotPresent < StandardError; end

private

  def relationship_for(course:)
    ProviderRelationshipPermissions.find_by(
      training_provider: course.provider,
      ratifying_provider: course.accredited_provider,
    )
  end

  def user_level_can?(permission:, provider:)
    @actor.provider_permissions.send(permission).exists?(provider: provider)
  end

  def permission_as_training_provider_user?(permission:, course:)
    permission_name = "training_provider_can_#{permission}"
    relationship = relationship_for course: course

    raise RelationshipNotPresent if relationship.blank?

    @actor.providers.include?(course.provider) &&
      relationship.send(permission_name)
  end

  def permission_as_ratifying_provider_user?(permission:, course:)
    permission_name = "ratifying_provider_can_#{permission}"
    relationship = relationship_for course: course

    raise RelationshipNotPresent if relationship.blank?

    @actor.providers.include?(course.accredited_provider) &&
      relationship.send(permission_name)
  end

  def full_authorisation?(permission:, course:)
    return true if @actor.is_a?(SupportUser)

    training_provider = course.provider
    ratifying_provider = course.accredited_provider

    # enforce user-level permissions
    add_error(permission, :requires_provider_user_permission) unless
      @actor.is_a?(VendorApiUser) ||
        user_level_can?(permission: permission, provider: training_provider) ||
        user_level_can?(permission: permission, provider: ratifying_provider)

    # enforce org-level permissions
    if ratifying_provider.present?
      ratifying_provider_can = permission_as_ratifying_provider_user?(permission: permission, course: course)
      training_provider_can = permission_as_training_provider_user?(permission: permission, course: course)

      # If user belongs to both providers, usually one of the two has org-level perm.
      if @actor.providers.include?(ratifying_provider) && @actor.providers.include?(training_provider)
        # If not, there is something wrong with the setup
        if [training_provider_can, ratifying_provider_can].none?
          add_error(permission, :requires_training_or_ratifying_provider_permission)
        # Check org-level and user-level permissions match for ratifying provider and training_provider
        elsif (!training_provider_can && !user_level_can?(permission: permission, provider: ratifying_provider)) ||
              (!ratifying_provider_can && !user_level_can?(permission: permission, provider: training_provider))
          add_error(permission, :requires_provider_user_permission)
        end
        # No additional checks if both providers have org-level access
      elsif @actor.providers.include?(ratifying_provider)
        add_error(permission, :requires_ratifying_provider_permission) unless ratifying_provider_can
      else
        add_error(permission, :requires_training_provider_permission) unless training_provider_can
      end
    end

    errors.blank?
  end

  def application_choice_visible_to_user?(application_choice:)
    return true if @actor.is_a?(SupportUser)

    GetApplicationChoicesForProviders.call(providers: @actor.providers, includes: [course_option: :course]).include?(application_choice)
  end

  def course_associated_with_user_providers?(course:)
    return true if @actor.is_a?(SupportUser)

    [course.provider, course.accredited_provider].compact.any? do |provider|
      @actor.providers.include?(provider)
    end
  end

  def add_error(permission, error)
    @errors[permission] ||= []
    @errors[permission] << error
  end

  def full_error_messages
    @errors.flat_map do |permission, msg_keys|
      msg_keys.map { |key| I18n.t("provider_authorisation.errors.#{permission}.#{key}") }
    end
  end

  def manageable_providers_from(provider_ids)
    manageable_provider_ids = ProviderPermissions
     .where(provider_id: provider_ids, provider_user: @actor, manage_organisations: true)
     .pluck(:provider_id)

    Provider.where(id: manageable_provider_ids).order(:name)
  end
end
