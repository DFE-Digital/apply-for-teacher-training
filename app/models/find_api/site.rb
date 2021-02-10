module FindAPI
  class Site < FindAPI::Resource
    belongs_to :recruitment_cycle, through: :provider, param: :recruitment_cycle_year
    belongs_to :provider, param: :provider_code

    def name
      location_name
    end

    def full_address
      [address1, address2, address3, address4, postcode]
        .reject(&:blank?)
        .join(', ')
    end
  end
end
