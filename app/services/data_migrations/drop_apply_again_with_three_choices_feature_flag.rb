module DataMigrations
  class DropApplyAgainWithThreeChoicesFeatureFlag
    TIMESTAMP = 20220228145523
    MANUAL_RUN = false

    def change
      Feature.where(name: :apply_again_with_three_choices).first&.destroy
    end
  end
end
