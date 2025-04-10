module GeocodeTestHelper
  def stub_geocoder
    Geocoder.configure(lookup: :test)

    Geocoder::Lookup::Test.set_default_stub(
      [
        {
          'coordinates' => [53.4807593, -2.2426305],
          'address' => 'Manchester',
          'state' => 'England',
          'country' => 'United Kingdom',
          'country_code' => 'UK',
        },
      ],
    )
  end
end
