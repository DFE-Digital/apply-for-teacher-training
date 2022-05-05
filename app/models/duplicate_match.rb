class DuplicateMatch < ApplicationRecord
  self.table_name = 'fraud_matches'
  audited

  has_many :candidates, foreign_key: 'fraud_match_id'

  def self.match_for(last_name:, postcode:, date_of_birth:)
    duplicate_match_query = DuplicateMatch.where(
      'TRIM(UPPER(last_name)) = ?',
      last_name.upcase.strip,
    ).where(date_of_birth: date_of_birth)

    if postcode.present?
      duplicate_match_query = duplicate_match_query.where(
        "REPLACE(UPPER(postcode), ' ', '') = ?",
        postcode.upcase.gsub(' ', ''),
      )
    end

    duplicate_match_query.first
  end
end
