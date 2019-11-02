class Reference < ApplicationRecord
  validates :email_address, presence: true, length: { maximum: 100 }
end
