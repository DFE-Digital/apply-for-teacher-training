class SubmitReference
  attr_reader :reference
  delegate :application_form, to: :reference

  def initialize(reference:)
    @reference = reference
  end

  def save!
    # Hacky way of preventing invalid references from being submitted until we
    # have proper validation on the review page.
    #
    # https://trello.com/c/5pEhlYqw/1266-dev-incorrectly-marked-reference-as-received
    if reference.feedback.nil? || reference.safeguarding_concerns.nil? || reference.relationship_correction.nil?
      raise 'Can\'t submit a reference without answers to all questions'
    end

    @reference.update!(feedback_status: 'feedback_provided')

    progress_application_if_enough_references_have_been_submitted

    CandidateMailer.reference_received(@reference).deliver_later
    RefereeMailer.reference_confirmation_email(application_form, reference).deliver_later
  end

private

  def progress_application_if_enough_references_have_been_submitted
    return unless there_are_now_enough_references_to_progress?

    ActiveRecord::Base.transaction do
      application_form.application_choices.each do |application_choice|
        ApplicationStateChange.new(application_choice).references_complete!
      end
    end

    SendApplicationsToProvider.new.call
  end

  # Only progress the applications if the reference that is being submitted is
  # the 2nd referee, since there might be more than 2 references per form. We
  # don't want to send the references to the provider *again* when the 3rd or
  # 4th reference is submitted.
  def there_are_now_enough_references_to_progress?
    application_form.application_references.feedback_provided.count == ApplicationForm::MINIMUM_COMPLETE_REFERENCES
  end
end
