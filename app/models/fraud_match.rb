class FraudMatch < ApplicationRecord
  audited

  has_many :candidates
end
