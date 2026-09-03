class Vendor < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
  validates :name, presence: true

  normalizes :name, with: ->(name) { name.strip.gsub('&', 'and').parameterize.underscore }

  has_many :providers, dependent: :destroy
  has_many :vendor_api_tokens, dependent: nil

  enum :status, {
    confirmed: 'confirmed',
    unconfirmed: 'unconfirmed',
  }
end
