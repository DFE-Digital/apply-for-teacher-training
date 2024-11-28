class AccountRecoveryRequest < ApplicationRecord
  belongs_to :candidate
  belongs_to :previous_candidate, optional: true, class_name: 'Candidate'

  validates :code, presence: true

  def self.generate_code
    code = SecureRandom.random_number(100_000..999_999)
    AccountRecoveryRequest.generate_code while AccountRecoveryRequest.exists?(code:)
    code
  end
end
