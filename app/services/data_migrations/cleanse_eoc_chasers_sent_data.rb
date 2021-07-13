module DataMigrations
  class CleanseEocChasersSentData
    TIMESTAMP = 20210713100502
    MANUAL_RUN = false

    def change
      ChaserSent
      .where('chaser_type = ? AND chasers_sent.created_at < ?', 'eoc_deadline_reminder', Time.zone.local(2021, 7, 12, 14, 55))
      .find_each(&:destroy!)
    end
  end
end
