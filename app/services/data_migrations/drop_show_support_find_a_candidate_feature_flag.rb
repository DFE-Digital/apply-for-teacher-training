module DataMigrations
  class DropShowSupportFindACandidateFeatureFlag
    TIMESTAMP = 20250502142359
    MANUAL_RUN = false

    def change
      Feature.where(name: :show_support_find_a_candidate).destroy_all
    end
  end
end
