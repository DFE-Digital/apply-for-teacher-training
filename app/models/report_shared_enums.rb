class ReportSharedEnums
  def self.england_regions
    {
      west_midlands: 'West Midlands (England)',
      north_west: 'North West (England)',
      london: 'London',
      nort_east: 'North East (England)',
      south_west: 'South West (England)',
      east_midlands: 'East Midlands (England)',
      east_of_england: 'East of England',
      yorkshire_and_the_humber: 'Yorkshire and The Humber',
      south_east: 'South East (England)',
    }
  end

  def self.england_regions_including_england
    { all_of_england_key.to_sym => all_of_england_value }
      .merge(england_regions)
  end

  def self.all_of_england_key
    'all_of_england'
  end

  def self.all_of_england_value
    'All of England'
  end

  def self.edi_categories
    {
      ethnic_group: 'Ethnic group',
      sex: 'Sex',
      age_group: 'Age group',
      disability: 'Disability',
    }
  end
end
