Geokit.default_units = :miles # others :kms, :nms, :meters
Geokit.default_formula = :sphere
Geokit::Geocoders.request_timeout = 3
Geokit::Geocoders::GoogleGeocoder.api_key = ENV['GOOGLE_MAPS_API_KEY']
Geokit::Geocoders.provider_order = [:google]
