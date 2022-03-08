module DataMigrations
  class MakeDecisionReminderNotificationSettingFeatureFlag
    TIMESTAMP = 20220308094833
    MANUAL_RUN = false

    def change
      Feature.where(name: :make_decision_reminder_notification_setting).first&.destroy
    end
  end
end
