module GeocodeTestHelper
  def stub_geocoder
    Geocoder.configure(lookup: :test)

    Geocoder::Lookup::Test.set_default_stub(
      [
        {
          'coordinates' => [53.8807593, -2.8426305],
          'address' => 'Manchester',
          'state' => 'England',
          'country' => 'United Kingdom',
          'country_code' => 'UK',
        },
      ],
    )
  end
end
