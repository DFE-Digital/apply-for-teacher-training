class DuplicateMatch < ApplicationRecord
  self.table_name = 'fraud_matches'
  audited

  has_many :candidates, foreign_key: 'fraud_match_id'

  def self.match_for(last_name:, postcode:, date_of_birth:)
    DuplicateMatch.where(
      'TRIM(UPPER(last_name)) = ?',
      last_name.upcase.strip,
    ).where(
      "REPLACE(UPPER(postcode), ' ', '') = ?",
      postcode.upcase.gsub(' ', ''),
    ).where(date_of_birth: date_of_birth).first
  end
end
