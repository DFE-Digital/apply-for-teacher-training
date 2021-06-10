module DataMigrations
  class BackfillNoneHesaDisabilitiesCodes
    TIMESTAMP = 20210610111514
    MANUAL_RUN = false

    def change
      no_disabilities_hesa_code = Hesa::Disability.find('no').hesa_code

      ApplicationForm
        .where("equality_and_diversity->>'disabilities' = '[]'")
        .where("equality_and_diversity->>'hesa_disabilities' = '[]' OR equality_and_diversity->>'hesa_disabilities' IS NULL")
        .find_each do |af|
        equality_and_diversity_data = af.equality_and_diversity
        equality_and_diversity_data['hesa_disabilities'] = [no_disabilities_hesa_code]
        af.update!(equality_and_diversity: equality_and_diversity_data, audit_comment: 'Backfilling HESA no disabilities codes')
      end
    end
  end
end
