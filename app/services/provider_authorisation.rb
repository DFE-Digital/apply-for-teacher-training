class ProviderAuthorisation
  attr_reader :errors

  def initialize(actor:)
    @actor = actor
    @errors = []
  end

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

  def can_manage_users_for?(provider)
    ProviderPermissions.exists?(
      provider: provider,
      provider_user: @actor,
      manage_users: true,
    )
  end

  def providers_that_actor_can_manage_organisations_for
    provider_ids = ProviderRelationshipPermissions
      .where(training_provider: @actor.providers)
      .or(
        ProviderRelationshipPermissions.where(
          ratifying_provider_id: @actor.providers,
        ),
      )
      .pluck(:ratifying_provider_id, :training_provider_id).flatten

    manageable_provider_ids = ProviderPermissions
      .where(provider_id: provider_ids, provider_user: @actor, manage_organisations: true)
      .pluck(:provider_id)

    Provider.where(id: manageable_provider_ids).order(:name)
  end

  def training_provider_relationships_that_actor_can_manage_organisations_for
    ProviderRelationshipPermissions
      .includes(:ratifying_provider, :training_provider)
      .joins("INNER JOIN #{ProviderPermissions.table_name} ON #{ProviderPermissions.table_name}.provider_id = provider_relationship_permissions.training_provider_id")
      .where(training_provider: @actor.providers)
      .where("#{ProviderPermissions.table_name}.provider_user_id": @actor.id, "#{ProviderPermissions.table_name}.manage_organisations": true)
      .order(:created_at)
  end

  def can_manage_organisations_for_at_least_one_provider?
    providers_that_actor_can_manage_organisations_for.any?
  end

  def can_make_decisions?(application_choice:, course_option_id:)
    MakeDecisionsAuthorisation.new(actor: @actor).can_make_decisions?(application_choice: application_choice, course_option_id: course_option_id)
  end

  def can_view_safeguarding_information?(course:)
    errors << :requires_provider_user_permission unless
      @actor.provider_permissions.view_safeguarding_information
        .exists?(provider: [course.provider, course.accredited_provider].compact)

    if course.accredited_provider.present?
      if @actor.providers.include?(course.provider)
        errors << :requires_training_provider_permission unless
          training_provider_can_view_safeguarding_information?(course: course)
      else
        errors << :requires_ratifying_provider_permission unless
          ratifying_provider_can_view_safeguarding_information?(course: course)
      end
    end

    errors.blank?
  end

  def can_view_diversity_information?(course:)
    @actor.provider_permissions.view_diversity_information
      .exists?(provider: [course.provider, course.accredited_provider].compact) &&
      (course.accredited_provider.blank? ||
        ratifying_provider_can_view_diversity_information?(course: course) ||
          training_provider_can_view_diversity_information?(course: course))
  end

  def can_manage_organisation?(provider:)
    return true if @actor.is_a?(SupportUser)

    @actor.provider_permissions.exists?(provider: provider, manage_organisations: true)
  end

  def assert_can_make_decisions!(application_choice:, course_option_id:)
    return if can_make_decisions?(application_choice: application_choice, course_option_id: course_option_id)

    raise NotAuthorisedError, 'You are not allowed to make decisions'
  end

  class NotAuthorisedError < StandardError; end

private

  def ratifying_provider_can_view_safeguarding_information?(course:)
    @actor.providers.include?(course.accredited_provider) &&
      ProviderRelationshipPermissions.exists?(
        ratifying_provider_can_view_safeguarding_information: true,
        ratifying_provider: course.accredited_provider,
        training_provider: course.provider,
      )
  end

  def training_provider_can_view_safeguarding_information?(course:)
    @actor.providers.include?(course.provider) &&
      ProviderRelationshipPermissions.exists?(
        training_provider_can_view_safeguarding_information: true,
        ratifying_provider: course.accredited_provider,
        training_provider: course.provider,
      )
  end

  def ratifying_provider_can_view_diversity_information?(course:)
    @actor.providers.include?(course.accredited_provider) &&
      ProviderRelationshipPermissions.exists?(
        ratifying_provider_can_view_diversity_information: true,
        ratifying_provider: course.accredited_provider,
        training_provider: course.provider,
      )
  end

  def training_provider_can_view_diversity_information?(course:)
    @actor.providers.include?(course.provider) &&
      ProviderRelationshipPermissions.exists?(
        training_provider_can_view_diversity_information: true,
        ratifying_provider: course.accredited_provider,
        training_provider: course.provider,
      )
  end
end
