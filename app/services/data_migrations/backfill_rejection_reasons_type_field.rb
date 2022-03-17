module DataMigrations
  class BackfillRejectionReasonsTypeField
    TIMESTAMP = 20220315121605
    MANUAL_RUN = false

    def change
      ApplicationChoice.where.not(structured_rejection_reasons: nil)
        .update_all(rejection_reasons_type: :reasons_for_rejection)

      ApplicationChoice.where.not(rejection_reason: nil)
        .where(structured_rejection_reasons: nil)
        .update_all(rejection_reasons_type: :rejection_reason)
    end
  end
end
