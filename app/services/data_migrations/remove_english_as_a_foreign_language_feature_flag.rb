module DataMigrations
  class RemoveEnglishAsAForeignLanguageFeatureFlag
    TIMESTAMP = 20260807103428
    MANUAL_RUN = false

    def change
      Feature.find_by(name: '2027_application_form_has_many_english_proficiencies')&.destroy
    end
  end
end
