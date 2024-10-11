module DataMigrations
  class RemoveTeacherDegreeApprenticeshipFeatureFlag
    TIMESTAMP = 20241011094842
    MANUAL_RUN = false

    def change
      Feature.where(name: :teacher_degree_aprenticeship).first&.destroy
    end
  end
end
