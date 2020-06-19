module RequiresMakeDecisionsPermission
  def self.included(base)
    base.class_eval do
      before_action :requires_make_decisions_permission
    end
  end

  def requires_make_decisions_permission
    auth = ProviderAuthorisation.new(actor: current_provider_user)

    if !auth.can_make_offer?(
      application_choice: @application_choice,
      course_option_id: @application_choice.offered_option.id,
    )
      raise ProviderInterface::AccessDenied.new({
        permission: 'make_decisions',
        training_provider: @application_choice.offered_course.provider,
        ratifying_provider: @application_choice.offered_course.accredited_provider,
        provider_user: current_provider_user,
      }), 'make_decisions required'
    end
  end
end
