module DataMigrations
  class FixMisspellingOfCaribbeanEthnicGroupAndSetHesaCodes
    TIMESTAMP = 20210513155136
    MANUAL_RUN = false

    def change
      application_forms = ApplicationForm
        .where("equality_and_diversity->>'ethnic_background' = 'Carribean'")
        .where("equality_and_diversity->>'hesa_ethnicity' IS NULL")

      application_forms.each do |af|
        equality_and_diversity = af.equality_and_diversity
        equality_and_diversity['ethnic_background'] = 'Caribbean'
        equality_and_diversity['hesa_ethnicity'] = Hesa::Ethnicity.find('Caribbean', af.recruitment_cycle_year)&.hesa_code

        af.update!(equality_and_diversity: equality_and_diversity, audit_comment: 'Fixing typo in ethnic background and adding correct hesa_ethnicity code')
      end
    end
  end
end
