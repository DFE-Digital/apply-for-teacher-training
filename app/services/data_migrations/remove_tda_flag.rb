module DataMigrations
  class RemoveTdaFlag
    TIMESTAMP = 20241108100246
    MANUAL_RUN = false

    def change
      Feature.where(name: 'teacher_degree_apprenticeship')&.destroy_all
    end
  end
end
