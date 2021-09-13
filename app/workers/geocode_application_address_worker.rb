class GeocodeApplicationAddressWorker
  include Sidekiq::Worker
  include SafePerformAsync

  sidekiq_options queue: :low_priority, retry: 5

  def perform(application_form_id)
    return unless Geocoder.config.api_key

    application_form = ApplicationForm.find(application_form_id)
    coordinates = application_form.geocode
    return if coordinates.nil?

    application_form.latitude, application_form.longitude = GeocodeFilter.outside_uk_or_unknown?(coordinates) ? [nil, nil] : coordinates

    application_form.save!
  end
end
