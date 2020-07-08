class OfferAuthorisation
  def initialize(actor:)
    @actor = actor
  end

  def can_make_offer?(application_choice:, course_option_id:)
    return true if @actor.is_a?(SupportUser)

    course_option = CourseOption.find(course_option_id)
    training_provider = course_option.provider
    ratifying_provider = course_option.course.accredited_provider

    # enforce org-level 'make_decisions' restriction
    return false if ratifying_provider &&
      FeatureFlag.active?(:enforce_provider_to_provider_permissions) &&
      FeatureFlag.active?(:providers_can_manage_users_and_permissions) &&
      provider_relationship_permissions_for_actor(
        training_provider: training_provider,
        ratifying_provider: ratifying_provider,
      ).none?(&:make_decisions)

    # enforce user-level 'make_decisions' restriction
    related_providers = [training_provider, ratifying_provider].compact
    return false if
      FeatureFlag.active?(:providers_can_manage_users_and_permissions) &&
        !actor_has_permission_to_make_decisions?(providers: related_providers)

    # check (indirect) relationship between course_option and @actor
    if course_option_id != application_choice.course_option.id
      application_choice_visible_to_user?(application_choice: application_choice) &&
        course_option_belongs_to_user_providers?(course_option: course_option)
    else
      application_choice_visible_to_user?(application_choice: application_choice)
    end
  end

private

  def course_option_belongs_to_user_providers?(course_option:)
    @actor.providers.include?(course_option.course.provider)
  end

  def application_choice_visible_to_user?(application_choice:)
    GetApplicationChoicesForProviders.call(providers: @actor.providers).include?(application_choice)
  end

  def actor_has_permission_to_make_decisions?(providers:)
    return true if @actor.is_a?(VendorApiUser)

    providers.any? do |provider|
      provider.users_with_make_decisions.include? @actor
    end
  end

  def provider_relationship_permissions_for_actor(training_provider:, ratifying_provider:)
    permissions = []

    if @actor.providers.include?(training_provider)
      permissions.push TrainingProviderPermissions.find_by(
        training_provider: training_provider,
        ratifying_provider: ratifying_provider,
      )
    end

    if ratifying_provider && @actor.providers.include?(ratifying_provider)
      permissions.push RatifyingProviderPermissions.find_by(
        training_provider: training_provider,
        ratifying_provider: ratifying_provider,
      )
    end

    permissions.compact
  end
end
