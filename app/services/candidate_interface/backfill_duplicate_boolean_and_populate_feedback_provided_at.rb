module CandidateInterface
  class BackfillDuplicateBooleanAndPopulateFeedbackProvidedAt
    def self.call
      references = ApplicationReference
                    .joins(:application_form)
                    .where('phase = ? AND feedback_status = ? AND feedback_provided_at is NULL', 'apply_2', 'feedback_provided')
      references.each do |reference|
        duplicate_references = ApplicationReference.feedback_provided.where(
          email_address: reference.email_address,
          name: reference.name,
          feedback: reference.feedback,
        )

        latest_feedback_provided_at = duplicate_references.map(&:feedback_provided_at).compact.min
        reference.update!(feedback_provided_at: latest_feedback_provided_at)
      end

      duplicate_references = ApplicationReference.where('feedback_provided_at < "references".created_at')
      duplicate_references.each { |reference| reference.update!(duplicate: true) }
    end
  end
end
