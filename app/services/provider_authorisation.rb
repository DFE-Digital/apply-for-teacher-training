class ProviderAuthorisation
  PERMISSION_METHOD_REGEXP = /^can_(\w+)\?$/.freeze

  def initialize(actor:)
    @actor = actor
  end

  def can_make_offer?(application_choice:, course_option_id: nil)
    return true if @actor.is_a?(SupportUser)

    supplied_course_option = CourseOption.find(course_option_id) if course_option_id

    training_provider = if supplied_course_option
                          supplied_course_option.provider
                        else
                          application_choice.offered_option.provider
                        end

    return false if
      FeatureFlag.active?('provider_make_decisions_restriction') &&
        !@actor.provider_permissions.make_decisions.exists?(provider: training_provider)

    if supplied_course_option && course_option_id != application_choice.course_option.id
      application_choice_visible_to_user?(application_choice: application_choice) && \
        course_option_belongs_to_user_providers?(course_option: supplied_course_option)
    else
      application_choice_visible_to_user?(application_choice: application_choice)
    end
  end

  def can_change_offer?(application_choice:, course_option_id:)
    new_course_option = CourseOption.find course_option_id
    @actor.is_a?(SupportUser) || \
      application_choice_visible_to_user?(application_choice: application_choice) && \
        course_option_belongs_to_user_providers?(course_option: new_course_option)
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

  # automatically generates assert_can...! methods e.g. #assert_can_make_offer! for #can_make_offer?
  instance_methods.select { |m| m.match PERMISSION_METHOD_REGEXP }.each do |method|
    permission_name = method.to_s.scan(PERMISSION_METHOD_REGEXP).last.first

    define_method("assert_can_#{permission_name}!") do |**keyword_args|
      raise(ProviderAuthorisation::NotAuthorisedError, method.to_s) unless send(method, **keyword_args)
    end
  end

  class NotAuthorisedError < StandardError; end

private

  def application_choice_visible_to_user?(application_choice:)
    GetApplicationChoicesForProviders.call(providers: @actor.providers).include?(application_choice)
  end

  def course_option_belongs_to_user_providers?(course_option:)
    @actor.providers.include?(course_option.course.provider)
  end

  def ratifying_provider_can_view_safeguarding_information?(course:)
    @actor.providers.include?(course.accredited_provider) &&
      ProviderInterface::AccreditedBodyPermissions
        .view_safeguarding_information
        .exists?(ratifying_provider: course.accredited_provider, training_provider: course.provider)
  end

  def training_provider_can_view_safeguarding_information?(course:)
    @actor.providers.include?(course.provider) &&
      ProviderInterface::TrainingProviderPermissions
        .view_safeguarding_information
        .exists?(ratifying_provider: course.accredited_provider, training_provider: course.provider)
  end
end
