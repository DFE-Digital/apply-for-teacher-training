module DataMigrations
  class RemoveFeedbackHelpfulFeatureFlag
    TIMESTAMP = 20240108154507
    MANUAL_RUN = false

    def change
      Feature.where(name: :is_this_feedback_helpful_survey).first&.destroy
    end
  end
end
