class Site < ApplicationRecord
  belongs_to :provider
  has_many :course_options

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

  def name_and_address
    if full_address.present?
      [name, full_address].join(', ')
    else
      name
    end
  end

  def geocoded?
    latitude.present? && longitude.present?
  end
end
