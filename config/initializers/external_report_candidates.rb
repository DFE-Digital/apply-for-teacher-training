module ExternalReportCandidates
  AREAS = {
    'eastern' => 'East',
    'east_midlands' => 'East Midlands',
    'london' => 'London',
    'north_east' => 'North East',
    'north_west' => 'North West',
    'northern_ireland' => 'Northern Ireland',
    'scotland' => 'Scotland',
    'south_east' => 'South East',
    'south_west' => 'South West',
    'wales' => 'Wales',
    'west_midlands' => 'West Midlands',
    'yorkshire_and_the_humber' => 'Yorkshire and The Humber',
    'european_economic_area' => 'European Economic Area',
    'rest_of_the_world' => 'Rest of the World',
  }.freeze

  AGE_GROUPS = [
    '21 and under',
    '22',
    '23',
    '24',
    '25 to 29',
    '30 to 34',
    '35 to 39',
    '40 to 44',
    '45 to 49',
    '50 to 54',
    '55 to 59',
    '60 to 64',
    '65 and over',
  ].freeze

  SEX = {
    'male' => 'Male',
    'female' => 'Female',
    'intersex' => 'Intersex',
    'Prefer not to say' => 'Prefer not to say',
    nil => 'Not provided',
  }.freeze

  STATUSES = [
    'Recruited',
    'Conditions pending',
    'Received an offer',
    'Awaiting provider decisions',
    'Unsuccessful',
  ].freeze
end
