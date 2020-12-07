class GeocodeApplicationAddressWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low_priority

  def perform(application_form_id)
    return unless Geocoder.config.api_key

    application_form = ApplicationForm.find(application_form_id)
    coordinates = application_form.geocode
    application_form.latitude, application_form.longitude = outside_uk?(coordinates) ? [nil, nil] : coordinates

    application_form.save!
  end

private

  SOUTHERLY_LIMIT = 49.51
  NORTHERLY_LIMIT = 60.51
  WESTERLY_LIMIT = -8.638
  EASTERLY_LIMIT = 1.46

  def outside_uk?(coordinates)
    latitude, longitude = coordinates
    latitude < SOUTHERLY_LIMIT ||
      latitude > NORTHERLY_LIMIT ||
      longitude < WESTERLY_LIMIT ||
      longitude > EASTERLY_LIMIT
  end
end
