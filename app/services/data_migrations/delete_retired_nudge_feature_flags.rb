module DataMigrations
  class DeleteRetiredNudgeFeatureFlags
    TIMESTAMP = 20220509095913
    MANUAL_RUN = false

    def change
      Feature.where(name: :candidate_nudge_emails).first&.destroy
      Feature.where(name: :candidate_nudge_course_choice_and_personal_statement).first&.destroy
    end
  end
end
