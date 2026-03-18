module DataMigrations
  class ToggleEnglishProficiencyQualificationStatusBooleans
    TIMESTAMP = 20260318102114
    MANUAL_RUN = false

    def change
      EnglishProficiency.has_qualification.update_all(has_qualification: true)
      EnglishProficiency.no_qualification.update_all(no_qualification: true)
      EnglishProficiency.qualification_not_needed.update_all(qualification_not_needed: true)
    end
  end
end
