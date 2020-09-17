class ReinstateConditionsMet
  include ActiveModel::Validations

  def initialize(actor:, application_choice:, course_option_id:)
    @auth = ProviderAuthorisation.new(actor: actor)
    @application_choice = application_choice
    @course_option_id = course_option_id
  end

  def save
    @auth.assert_can_make_decisions!(application_choice: @application_choice, course_option_id: @course_option_id)

    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(@application_choice).reinstate_conditions_met!
      @application_choice.update(
        offered_course_option_id: @course_option_id,
        recruited_at: Time.zone.now,
      )
    end
  rescue Workflow::NoTransitionAllowed
    errors.add(
      :base,
      I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
    )
    false
  end
end
