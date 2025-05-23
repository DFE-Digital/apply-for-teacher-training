module DataMigrations
  class RemoveVisaSponsorshipDeadlineFeatureFlag
    TIMESTAMP = 20250521152819
    MANUAL_RUN = false

    def change
      Feature.where(name: :early_application_deadlines_for_candidates_with_visa_sponsorship).destroy_all
    end
  end
end
