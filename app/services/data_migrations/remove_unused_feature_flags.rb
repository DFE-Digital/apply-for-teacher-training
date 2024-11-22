module DataMigrations
  class RemoveUnusedFeatureFlags
    TIMESTAMP = 20241122140221
    MANUAL_RUN = false

    def change
      feature_flags = %i[
        deadline_notices
        lock_external_report_to_january_2022
        monthly_statistics_preview
        reference_nudges
        sample_applications_factory
        structured_reference_condition
        continuous_applications
        block_candidate_sign_in
      ]
      Feature.where(name: feature_flags).delete_all
    end
  end
end
