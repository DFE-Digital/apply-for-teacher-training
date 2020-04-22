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

    if enough_references_have_been_submitted?
      progress_applications
    else
      reference_feedback_provided!
    end

    CandidateMailer.reference_received(@reference).deliver_later
    RefereeMailer.reference_confirmation_email(application_form, reference).deliver_later
  end

private

  # Only progress the applications if the reference that is being submitted is
  # the 2nd referee, since there might be more than 2 references per form. We
  # don't want to send the references to the provider *again* when the 3rd or
  # 4th reference is submitted.
  def enough_references_have_been_submitted?
    (
      application_form.application_references.feedback_provided + [@reference]
    ).uniq.count == ApplicationForm::MINIMUM_COMPLETE_REFERENCES
  end

  def reference_feedback_provided!
    @reference.update!(feedback_status: 'feedback_provided')
  end

  def progress_applications
    ActiveRecord::Base.transaction do
      reference_feedback_provided!
      application_form.application_choices.each do |application_choice|
        ApplicationStateChange.new(application_choice).references_complete!
      end
    end

    SendApplicationsToProvider.new.call
  end
end
