class FraudMatch < ApplicationRecord
  audited

  has_many :candidates

  def self.match_for(last_name:, postcode:, date_of_birth:)
    FraudMatch.where(
      'TRIM(UPPER(last_name)) = ?',
      last_name.upcase.strip,
    ).where(
      "REPLACE(UPPER(postcode), ' ', '') = ?",
      postcode.upcase.gsub(' ', ''),
    ).where(date_of_birth: date_of_birth).first
  end
end
