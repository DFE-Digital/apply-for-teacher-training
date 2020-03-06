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

  # automatically generates assert_can...! methods e.g. #assert_can_make_offer! for #can_make_offer?
  instance_methods.select { |m| m.match PERMISSION_METHOD_REGEXP }.each do |method|
    permission_name = method.to_s.scan(PERMISSION_METHOD_REGEXP).last.first

    define_method("assert_can_#{permission_name}!") do |**keyword_args|
      raise(ProviderAuthorisation::NotAuthorisedError, method.to_s) unless self.send(method, **keyword_args)
    end
  end

  class NotAuthorisedError < StandardError; end
end
