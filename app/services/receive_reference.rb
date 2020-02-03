class ReceiveReference
  attr_reader :reference, :feedback

  def initialize(reference:, feedback:)
    @reference = reference
    @feedback = feedback
  end

  def save
    ActiveRecord::Base.transaction do
      @reference.update!(feedback: @feedback, feedback_status: 'feedback_provided')
      progress_application_if_enough_references_have_been_submitted
    end
    true
  rescue Workflow::NoTransitionAllowed
    errors.add(
      :base,
      I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
    )
    false
  end

private

  def progress_application_if_enough_references_have_been_submitted
    application_form = reference.application_form

    return unless application_form.application_references_complete?

    application_form.application_choices.each do |application_choice|
      ApplicationStateChange.new(application_choice).references_complete!

      if application_choice.edit_by <= Time.zone.now
        SendApplicationToProvider.new(application_choice: application_choice).call
      end
    end
  end
end
