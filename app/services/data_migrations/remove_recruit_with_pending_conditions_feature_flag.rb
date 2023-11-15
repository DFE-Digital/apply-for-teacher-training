module DataMigrations
  class RemoveRecruitWithPendingConditionsFeatureFlag
    TIMESTAMP = 20231115095550
    MANUAL_RUN = false

    def change
      Feature.where(name: 'recruit_with_pending_conditions').delete_all
    end
  end
end
