module GeocodeTestHelper
  def stub_geocoder
    Geocoder.configure(lookup: :test)

    Geocoder::Lookup::Test.set_default_stub(
      [
        {
          'coordinates' => [51.4524877, -0.1204749],
          'address' => 'AA Teamworks W Yorks SCITT, School Street, Greetland, Halifax, West Yorkshire HX4 8JB',
          'state' => 'England',
          'country' => 'United Kingdom',
          'country_code' => 'UK',
        },
      ],
    )
  end
end
