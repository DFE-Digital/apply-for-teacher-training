module DataMigrations
  class RemoveOneLoginPreReleaseBannersFeatureFlag
    TIMESTAMP = 20250120150435
    MANUAL_RUN = false

    def change
      Feature.where(name: :one_login_pre_release_banners).delete_all
    end
  end
end
