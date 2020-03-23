class ProviderAuthorisation
  PERMISSION_METHOD_REGEXP = /^can_(\w+)\?$/.freeze

  def initialize(actor:)
    @actor = actor
  end

  def can_make_offer?(application_choice:, course_option_id: nil)
    return true if @actor.is_a?(SupportUser)

    supplied_course_option = CourseOption.find(course_option_id) if course_option_id
    if supplied_course_option && course_option_id != application_choice.course_option.id
      application_choice_belongs_to_user_providers?(application_choice: application_choice) && \
        course_option_belongs_to_user_providers?(course_option: supplied_course_option)
    else
      application_choice_belongs_to_user_providers?(application_choice: application_choice)
    end
  end

  def can_change_offer?(application_choice:, course_option_id:)
    new_course_option = CourseOption.find course_option_id
    @actor.is_a?(SupportUser) || \
      application_choice_belongs_to_user_providers?(application_choice: application_choice) && \
        course_option_belongs_to_user_providers?(course_option: new_course_option)
  end

  # automatically generates assert_can...! methods e.g. #assert_can_make_offer! for #can_make_offer?
  instance_methods.select { |m| m.match PERMISSION_METHOD_REGEXP }.each do |method|
    permission_name = method.to_s.scan(PERMISSION_METHOD_REGEXP).last.first

    define_method("assert_can_#{permission_name}!") do |**keyword_args|
      raise(ProviderAuthorisation::NotAuthorisedError, method.to_s) unless self.send(method, **keyword_args)
    end
  end

  class NotAuthorisedError < StandardError; end

private

  def application_choice_belongs_to_user_providers?(application_choice:)
    @actor.providers.include?(application_choice.course.provider)
  end

  def course_option_belongs_to_user_providers?(course_option:)
    @actor.providers.include?(course_option.course.provider)
  end
end
