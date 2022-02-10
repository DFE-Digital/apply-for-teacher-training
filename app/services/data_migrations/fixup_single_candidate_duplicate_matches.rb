module DataMigrations
  class FixupSingleCandidateDuplicateMatches
    TIMESTAMP = 20220125153152
    MANUAL_RUN = true

    FIND_DUPLICATE_FRAUD_MATCHES =
      "select count(*), TRIM(UPPER(last_name)) as last_name, REPLACE(UPPER(postcode), ' ', '') as postcode, date_of_birth, array_agg(id ORDER BY id) as fraud_match_ids
      from fraud_matches
      group by TRIM(UPPER(last_name)), REPLACE(UPPER(postcode), ' ', ''), date_of_birth
      having count(*) > 1;".freeze

    def change
      results = ActiveRecord::Base.connection.execute(FIND_DUPLICATE_FRAUD_MATCHES)
      results.type_map = PG::BasicTypeMapForResults.new(ActiveRecord::Base.connection.raw_connection)
      results.each do |result|
        fraud_matches = DuplicateMatch.where(id: result['fraud_match_ids'])
        first_fraud_match = fraud_matches.first
        all_candidates = fraud_matches.inject([]) { |candidates, fraud_match| candidates + fraud_match.candidates }
        first_fraud_match.update(candidates: all_candidates)
        fraud_matches
          .reject { |fraud_match| fraud_match.id == first_fraud_match.id }
          .each(&:destroy)
      end
    end

    def dry_run
      results = ActiveRecord::Base.connection.execute(FIND_DUPLICATE_FRAUD_MATCHES)
      results.type_map = PG::BasicTypeMapForResults.new(ActiveRecord::Base.connection.raw_connection)
      results.each do |result|
        fraud_matches = DuplicateMatch.where(id: result['fraud_match_ids'])
        first_fraud_match = fraud_matches.first
        all_candidates = fraud_matches.inject([]) { |candidates, fraud_match| candidates + fraud_match.candidates }
        Rails.logger.debug { "Adding candidates #{all_candidates.map(&:id)} to fraud match #{first_fraud_match.id}" }
        fraud_matches
          .reject { |fraud_match| fraud_match.id == first_fraud_match.id }
          .each { |fraud_match| Rails.logger.debug "Delete fraud match #{fraud_match.id}" }
      end
    end
  end
end
