class ReinstatePendingConditions
  include ActiveModel::Validations

  def initialize(actor:, application_choice:, course_option_id:)
    @auth = ProviderAuthorisation.new(actor: actor)
    @application_choice = application_choice
    @course_option_id = course_option_id
  end

  def save
    @auth.assert_can_make_decisions!(application_choice: @application_choice, course_option_id: @application_choice.offered_option.id)

    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(@application_choice).reinstate_pending_conditions!
      @application_choice.update(offered_course_option_id: @course_option_id)
    end
  rescue Workflow::NoTransitionAllowed
    errors.add(
      :base,
      I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
    )
    false
  end
end
