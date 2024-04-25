class Vendor < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
  validates :name, presence: true

  normalizes :name, with: ->(name) { name.strip.gsub('&', 'and').parameterize.underscore }
  has_many :providers
end
