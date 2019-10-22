class Site < ApplicationRecord
  belongs_to :provider

  validates :code, presence: true
  validates :name, presence: true
end
