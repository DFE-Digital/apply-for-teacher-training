module DataMigrations
  class DropGroupedInviteEmailFeatureFlag
    TIMESTAMP = 20250715162833
    MANUAL_RUN = false

    def change
      Feature.where(name: :grouped_invite_email).destroy_all
    end
  end
end
