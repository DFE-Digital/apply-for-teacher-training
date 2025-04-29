module DataMigrations
  class BackfillConfidentialData
    TIMESTAMP = 20250428151006
    MANUAL_RUN = false

    def change
      # There are only 29 of these in production, so it is safe to iterate over them
      # See blazer query
      # https://www.apply-for-teacher-training.service.gov.uk/support/blazer/queries/1152-no-confidential-answer-2025-references-with-feedback-provided/edit
      references_query.find_each do |reference|
        reference.update(audit_comment:, confidential: true)
      end
    end

  private

    def references_query
      ApplicationReference
        .where(confidential: nil, feedback_status: 'feedback_provided')
        .joins(:application_form).where('application_form.recruitment_cycle_year': 2025)
    end

    def audit_comment
      'Backfilling confidential data for references added in support, see trello ticket: https://trello.com/c/ncfBrX1Q'
    end
  end
end
