module DataMigrations
  class RemoveDuplicateMatchingFeatureFlag
    TIMESTAMP = 20220208120712
    MANUAL_RUN = false

    def change
      Feature.where(name: :duplicate_matching).first&.destroy
    end
  end
end
