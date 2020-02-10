class ProviderAuthorisation
  PERMISSION_METHOD_REGEXP = /^can_(\w+)\?$/.freeze

  def initialize(actor:)
    @actor = actor
  end

  def can_make_offer?(application_choice:)
    @actor.is_a?(SupportUser) || @actor.providers.include?(application_choice.course.provider)
  end

  def assert_can_make_offer!(application_choice:)
    raise ProviderAuthorisation::NotAuthorisedError, 'assert_can_make_offer!' if !can_make_offer?(application_choice: application_choice)
  end

  class NotAuthorisedError < StandardError; end
end
