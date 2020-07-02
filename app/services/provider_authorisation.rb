class ProviderAuthorisation
  PERMISSION_METHOD_REGEXP = /^can_(\w+)\?$/.freeze

  def initialize(actor:)
    @actor = actor
  end

  def can_make_offer?(application_choice:, course_option_id:)
    OfferAuthorisation.new(actor: @actor).can_make_offer?(application_choice: application_choice, course_option_id: course_option_id)
  end

  def can_view_safeguarding_information?(course:)
    if FeatureFlag.active?(:enforce_provider_to_provider_permissions)
      @actor.provider_permissions.view_safeguarding_information
        .exists?(provider: [course.provider, course.accredited_provider].compact) &&
        (course.accredited_provider.blank? ||
          ratifying_provider_can_view_safeguarding_information?(course: course) ||
            training_provider_can_view_safeguarding_information?(course: course))
    else
      @actor.provider_permissions.view_safeguarding_information
        .exists?(provider: [course.provider, course.accredited_provider].compact)
    end
  end

  def can_manage_organisation?(provider:)
    return true if @actor.is_a?(SupportUser)

    @actor.provider_permissions.exists?(provider: provider, manage_organisations: true)
  end

  # automatically generates assert_can...! methods e.g. #assert_can_make_offer! for #can_make_offer?
  instance_methods.select { |m| m.match PERMISSION_METHOD_REGEXP }.each do |method|
    permission_name = method.to_s.scan(PERMISSION_METHOD_REGEXP).last.first

    define_method("assert_can_#{permission_name}!") do |**keyword_args|
      raise(ProviderAuthorisation::NotAuthorisedError, method.to_s) unless send(method, **keyword_args)
    end
  end

  class NotAuthorisedError < StandardError; end

private

  def ratifying_provider_can_view_safeguarding_information?(course:)
    @actor.providers.include?(course.accredited_provider) &&
      RatifyingProviderPermissions
        .view_safeguarding_information
        .exists?(ratifying_provider: course.accredited_provider, training_provider: course.provider)
  end

  def training_provider_can_view_safeguarding_information?(course:)
    @actor.providers.include?(course.provider) &&
      TrainingProviderPermissions
        .view_safeguarding_information
        .exists?(ratifying_provider: course.accredited_provider, training_provider: course.provider)
  end
end
