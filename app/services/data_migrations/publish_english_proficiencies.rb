module DataMigrations
  class PublishEnglishProficiencies
    TIMESTAMP = 20260318100229
    MANUAL_RUN = false

    def change
      EnglishProficiency.update_all(draft: false)
    end
  end
end
