module DataMigrations
  class RemoveOnePersonalStatementFeatureFlag
    TIMESTAMP = 20240108135715
    MANUAL_RUN = false

    def change
      Feature.where(name: :one_personal_statementt).delete_all
    end
  end
end
