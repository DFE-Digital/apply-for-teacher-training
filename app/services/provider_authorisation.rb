class ProviderAuthorisation
  PERMISSION_METHOD_REGEXP = /^can_(\w+)\?$/.freeze

  def initialize(actor:)
    @actor = actor
  end

  def can_make_offer?(application_choice:)
    @actor.is_a?(SupportUser) || @actor.providers.include?(application_choice.course.provider)
  end

  def can_change_offer?(application_choice:, course_option_id:)
    course_option = CourseOption.find course_option_id
    if @actor.is_a?(SupportUser)
      true
    else
      authorised_user = @actor.providers.include?(application_choice.course.provider)
      valid_option = @actor.providers.include?(course_option.course.provider)
      authorised_user && valid_option
    end
  end

  def assert_can_make_offer!(application_choice:)
    raise ProviderAuthorisation::NotAuthorisedError, 'assert_can_make_offer!' if !can_make_offer?(application_choice: application_choice)
  end

  def assert_can_change_offer!(application_choice:, course_option_id:)
    raise ProviderAuthorisation::NotAuthorisedError, 'assert_can_change_offer!' if !can_change_offer?(application_choice: application_choice, course_option_id: course_option_id)
  end

  class NotAuthorisedError < StandardError; end
end
