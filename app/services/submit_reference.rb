class SubmitReference
  attr_reader :reference
  delegate :application_form, to: :reference

  def initialize(reference:)
    @reference = reference
  end

  def save!
    if enough_references_have_been_submitted?
      # With the decoupled_references feature active, we should be preventing
      # submission of the application unless the MINIMUM_COMPLETE_REFERENCES
      # have been provided. We also no longer allow the candidate to manually
      # mark the section complete - it is considered complete when the minimum
      # references are given. We check the references directly when attempting
      # to submit the form, rather than inspecting the
      # ApplicationForm#references_completed flag.
      #
      # As such, this method only needs to update the state of the reference,
      # not the application form.
      #
      # TODO: drop the ApplicationForm#references_completed column when
      # removing the decoupled_references feature flag.
      if FeatureFlag.active?(:decoupled_references)
        reference_feedback_provided!

        application_form.application_references.select(&:feedback_requested?).each do |reference|
          # TODO: use the CancelReference service once George merges it in. I'm thinking of adding another
          # argument to the service which is something like maximum_references_received: false)
          # which will trigger a different slack message for these cancelled references.

          reference.update!(feedback_status: 'cancelled')
          RefereeMailer.reference_cancelled_email(reference).deliver_later
        end
      else
        progress_applications
      end
    else
      reference_feedback_provided!
    end

    CandidateMailer.reference_received(@reference).deliver_later
    RefereeMailer.reference_confirmation_email(application_form, reference).deliver_later
  end

private

  # Only progress the applications if the reference that is being submitted is
  # the 2nd referee, since there might be more than 2 references per form. We
  # do not want to send the references to the provider *again* when the 3rd or
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
      application_form.application_choices.awaiting_references.each do |application_choice|
        ApplicationStateChange.new(application_choice).references_complete!

        next unless application_form.candidate_has_previously_applied?

        # If the candidate has previously applied, they have less of a need to
        # edit the application. Hence, we clear out the usual 7-day edit window
        # by resetting the `edit_by` time.
        application_form.update!(edit_by: Time.zone.now)
      end
    end

    SendApplicationsToProvider.new.call
  end
end
