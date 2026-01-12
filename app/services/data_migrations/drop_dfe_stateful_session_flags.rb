module DataMigrations
  class DropDfEStatefulSessionFlags
    TIMESTAMP = 20260112152257
    MANUAL_RUN = false

    def change
      Feature.where(name: :separate_dsi_controllers).destroy_all
      Feature.where(name: :dsi_stateful_session).destroy_all
    end
  end
end
