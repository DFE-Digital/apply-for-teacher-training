module CandidateInterface
  module DecoupledReferences
    class RequestReference
      REFEREE_BOT_EMAIL_ADDRESSES = ['refbot1@example.com', 'refbot2@example.com'].freeze

      def call(reference, flash)
        if reference.not_requested_yet? || reference.cancelled? || reference.cancelled_at_end_of_cycle? || reference.email_bounced?
          RefereeMailer.reference_request_email(reference).deliver_later
          reference.update!(feedback_status: 'feedback_requested', requested_at: Time.zone.now)
          auto_approve_reference_in_sandbox(reference)

          flash[:success] = "Reference request sent to #{reference.name}"
        else
          flash[:warning] = "Reference request already sent to #{reference.name}"
        end
      end

    private

      def auto_approve_reference_in_sandbox(reference)
        auto_approve_reference(reference) if HostingEnvironment.sandbox_mode? && email_address_is_a_bot?(reference)
      end

      def auto_approve_reference(reference)
        reference.update!(
          feedback_status: :feedback_provided,
          relationship_correction: '',
          safeguarding_concerns: '',
          safeguarding_concerns_status: :no_safeguarding_concerns_to_declare,
          feedback: I18n.t('new_referee_request.auto_approve_feedback'),
        )

        SubmitReference.new(
          reference: reference,
        ).save!
      end

      def email_address_is_a_bot?(reference)
        REFEREE_BOT_EMAIL_ADDRESSES.include?(reference.email_address)
      end
    end
  end
end
