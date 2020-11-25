class GeocodeApplicationAddressWorker
  include Sidekiq::Worker

  def perform(application_form_id)
    return unless Geocoder.config.api_key

    application_form = ApplicationForm.find(application_form_id)
    application_form.latitude, application_form.longitude = application_form.geocode

    application_form.save!
  end
end
