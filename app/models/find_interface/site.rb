class FindInterface::Site < FindInterface::Base
  belongs_to :recruitment_cycle, through: :provider, param: :recruitment_cycle_year
  belongs_to :provider, param: :provider_code
  has_one :site_status

  properties :code, :location_name, :address1, :address2, :address3
  properties :address4, :postcode, :latitude, :longitude
end
