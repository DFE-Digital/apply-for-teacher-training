class ReceiveReference
  attr_reader :referee_email
  attr_reader :feedback

  def initialize(reference:, feedback:)
    @reference = reference
    @application_form = reference.application_form
    @feedback = feedback
  end

  def save
    ActiveRecord::Base.transaction do
      @reference.update!(feedback: @feedback, feedback_status: 'feedback_provided')

      if @application_form.application_references_complete?
        @application_form.application_choices.includes(:course_option).each do |application_choice|
          complete_references(application_choice)
        end
      end
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

  def complete_references(application_choice)
    ApplicationStateChange.new(application_choice).references_complete!
    if application_choice.edit_by <= Time.zone.now
      SendApplicationToProvider.new(application_choice: application_choice).call
    end
  end
end
