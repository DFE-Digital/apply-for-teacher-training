module DataMigrations
  class RemoveNewDegreeFlowFeatureFlag
    TIMESTAMP = 20221019111412
    MANUAL_RUN = false

    def change
      Feature.find_by(name: 'new_degree_flow')&.destroy
    end
  end
end
