class ReceiveReference
  attr_reader :reference, :feedback
  delegate :application_form, to: :reference

  def initialize(reference:, feedback:)
    @reference = reference
    @feedback = feedback
  end

  def save!
    ActiveRecord::Base.transaction do
      @reference.update!(feedback: @feedback, feedback_status: 'feedback_provided')
      progress_application_if_enough_references_have_been_submitted
    end
  end

private

  def progress_application_if_enough_references_have_been_submitted
    return unless there_are_now_enough_references_to_progress?

    if application_form.application_choices.all?(&:awaiting_references?)
      application_form.application_choices.each do |application_choice|
        ApplicationStateChange.new(application_choice).references_complete!
      end
      SendApplicationsToProvider.new.call
    else
      # Perhaps only send an email to the provider that a new reference has
      # come in.
    end
  end

  # Only progress the applications if the reference that is being submitted is
  # the 2nd referee, since there might be more than 2 references per form
  # in the future.
  def there_are_now_enough_references_to_progress?
    application_form.application_references.feedback_provided.count == ApplicationForm::MINIMUM_COMPLETE_REFERENCES
  end
end
