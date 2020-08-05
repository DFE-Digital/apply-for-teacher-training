class MakeDecisionsAuthorisation
  def initialize(actor:)
    @actor = actor
  end

  def can_make_decisions?(application_choice:, course_option_id:)
    return true if @actor.is_a?(SupportUser)

    course_option = CourseOption.find(course_option_id)
    training_provider = course_option.provider
    ratifying_provider = course_option.course.accredited_provider

    if FeatureFlag.active?(:providers_can_manage_users_and_permissions)
      # enforce user-level 'make_decisions' restriction
      related_providers = [training_provider, ratifying_provider].compact
      return false if !actor_has_permission_to_make_decisions?(providers: related_providers)

      if FeatureFlag.active?(:enforce_provider_to_provider_permissions)
        # enforce org-level 'make_decisions' restriction
        if ratifying_provider
          return false unless actor_has_permissions_via_provider_to_provider_permissions?(
            training_provider: training_provider,
            ratifying_provider: ratifying_provider,
          )
        end
      end
    end

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

  def actor_has_permissions_via_provider_to_provider_permissions?(training_provider:, ratifying_provider:)
    relationship = ProviderRelationshipPermissions.find_by!(
      training_provider: training_provider,
      ratifying_provider: ratifying_provider,
    )

    if @actor.providers.include?(training_provider)
      return true if relationship.training_provider_can_make_decisions?
    end

    if @actor.providers.include?(ratifying_provider)
      return true if relationship.ratifying_provider_can_make_decisions?
    end
  end

  def actor_has_permission_to_make_decisions?(providers:)
    return true if @actor.is_a?(VendorApiUser)

    providers.any? do |provider|
      provider.users_with_make_decisions.include? @actor
    end
  end
end
