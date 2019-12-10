class Site < ApplicationRecord
  belongs_to :provider

  validates :code, presence: true
  validates :name, presence: true

  CODE_LENGTH = 5

  def name_and_code
    "#{name} (#{code})"
  end

  def full_address
    [address_line1, address_line2, address_line3, address_line4, postcode]
      .reject(&:blank?)
      .join(', ')
  end
end
