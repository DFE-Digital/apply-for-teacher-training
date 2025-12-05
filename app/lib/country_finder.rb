class CountryFinder
  class << self
    # This class is different from the DomicileResolver and both are necessary.
    # It returns the data that the user inputted via the iso code, regardless of whether it maps to a valid hesa code or not
    # The DomicileResolver is for mapping the iso data to hesa data for reporting.
    def find_name_from_iso_code(iso_code)
      COUNTRIES_AND_TERRITORIES[iso_code] || legacy_look_up(iso_code) || 'N/A'
    end

  private

    def legacy_look_up(iso_code)
      LEGACY_LOOK_UP_TABLE.dig(iso_code, :legacy_name)
    end
  end
end
