class Provider < ApplicationRecord
  has_many :courses
  has_many :sites
  has_many :course_options, through: :courses
  has_many :application_choices, through: :course_options

  has_many :provider_users_providers, dependent: :destroy
  has_many :provider_users, through: :provider_users_providers
  has_many :provider_agreements

  enum region_code: {
    east_midlands: 'east_midlands',
    eastern: 'eastern',
    london: 'london',
    no_region: 'no_region',
    north_east: 'north_east',
    north_west: 'north_west',
    scotland: 'scotland',
    south_east: 'south_east',
    south_west: 'south_west',
    wales: 'wales',
    west_midlands: 'west_midlands',
    yorkshire_and_the_humber: 'yorkshire_and_the_humber',
  }

  def name_and_code
    "#{name} (#{code})"
  end

  def accredited_courses
    Course.where(accrediting_provider: self)
  end
end
