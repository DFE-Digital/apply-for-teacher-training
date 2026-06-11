module DataMigrations
  class RemoveInterviewHandlingFeatureFlag
    TIMESTAMP = 20260611102613
    MANUAL_RUN = false

    def change
      Feature.find_by(name: :interview_handling)&.destroy
    end
  end
end
