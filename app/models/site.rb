class Site < ApplicationRecord
  belongs_to :provider

  validates :code, presence: true
  validates :name, presence: true

  def name_and_code
    "#{name} (#{code})"
  end
end
