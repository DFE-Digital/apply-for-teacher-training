module DataMigrations
  class RemoveOnePersonalStatementFeatureFlag
    TIMESTAMP = 20240108135715
    MANUAL_RUN = false

    def change
      Feature.where(name: :one_personal_statement).first&.destroy
    end
  end
end
