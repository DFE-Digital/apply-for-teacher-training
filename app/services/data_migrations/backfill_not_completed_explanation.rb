module DataMigrations
  class BackfillNotCompletedExplanation
    TIMESTAMP = 20210915172449
    MANUAL_RUN = false

    def change
      ApplicationQualification
      .gcse
      .where.not(missing_explanation: nil)
      .where.not(missing_explanation: '')
      .find_each(batch_size: 100) do |gcse|
        missing_explanation = gcse.missing_explanation
        gcse.update_columns(
          not_completed_explanation: missing_explanation,
          currently_completing_qualification: true,
          missing_explanation: nil,
        )
      end
    end
  end
end
