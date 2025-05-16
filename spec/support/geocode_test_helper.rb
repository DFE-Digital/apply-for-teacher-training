module GeocodeTestHelper
  def stub_geocoder
    Geocoder.configure(lookup: :test)

    Geocoder::Lookup::Test.set_default_stub(
      [
        {
          'coordinates' => [53.4706519, -2.2954452],
          'address' => 'Salford',
          'state' => 'England',
          'country' => 'United Kingdom',
          'country_code' => 'UK',
        },
      ],
    )

    Geocoder::Lookup::Test.add_stub(
      'm4_place_id', [
        {
          'coordinates' => [53.4874112, -2.2274845],
          'address' => 'M4 Manchester',
          'state' => 'England',
          'country' => 'United Kingdom',
          'country_code' => 'UK',
        },
      ]
    )

    Geocoder::Lookup::Test.add_stub('wrong_location', [])
  end
end
