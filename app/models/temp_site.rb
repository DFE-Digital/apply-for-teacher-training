class TempSite < ApplicationRecord
  belongs_to :provider
  has_many :course_options
  has_many :courses, through: :course_options

  validates :code, presence: true
  validates :name, presence: true

  CODE_LENGTH = 5

  def name_and_code
    "#{name} (#{code})"
  end

  def self.for_recruitment_cycle_years(recruitment_cycle_years = [])
    joins(:courses)
    .where(courses: { recruitment_cycle_year: recruitment_cycle_years })
    .distinct
  end

  def full_address(join_by = ', ')
    [address_line1, address_line2, address_line3, address_line4, postcode]
      .compact_blank
      .join(join_by)
  end

  def name_and_address(join_by = ', ')
    if full_address.present?
      [name, full_address(join_by)].join(join_by)
    else
      name
    end
  end

  def geocoded?
    latitude.present? && longitude.present?
  end
end
