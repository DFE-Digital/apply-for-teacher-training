class DuplicateMatch < ApplicationRecord
  self.table_name = 'fraud_matches'
  audited

  has_many :candidates, foreign_key: 'fraud_match_id', dependent: nil

  def self.match_for(last_name:, postcode:, date_of_birth:)
    where('TRIM(UPPER(unaccent(last_name))) = TRIM(UPPER(unaccent(?)))', last_name)
      .where(date_of_birth:)
      .where("COALESCE(REPLACE(UPPER(postcode), ' ', ''), '') = ?", postcode.to_s.upcase.delete(' '))
      .first
  end
end
