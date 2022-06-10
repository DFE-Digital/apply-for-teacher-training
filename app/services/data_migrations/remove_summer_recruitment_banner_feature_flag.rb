module DataMigrations
  class RemoveSummerRecruitmentBannerFeatureFlag
    TIMESTAMP = 20220610155527
    MANUAL_RUN = false

    def change
      Feature.find_by(name: :summer_recruitment_banner)&.destroy
    end
  end
end
