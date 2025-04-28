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
  end
end
