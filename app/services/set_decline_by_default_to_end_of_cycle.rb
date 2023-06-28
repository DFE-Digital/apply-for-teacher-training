class SetDeclineByDefaultToEndOfCycle
  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    # Only set Decline by Default (DBD) date if all applications have been acted upon.
    return if pending_decisions?

    ActiveRecord::Base.transaction do
      filtered_application_choices.each do |application_choice|
        application_choice.update!(
          decline_by_default_at: CycleTimetable.next_apply_deadline,
        )
      end
    end
  end

private

  attr_reader :application_form

  def filtered_application_choices
    application_form
      .application_choices
      .offer
      .where(decline_by_default_at: nil)
      .or(ApplicationChoice.where.not(decline_by_default_at: CycleTimetable.next_apply_deadline))
  end

  def pending_decisions?
    application_form.awaiting_provider_decisions?
  end
end
