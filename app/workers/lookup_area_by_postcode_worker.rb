class LookupAreaByPostcodeWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low_priority, retry: 5

  def perform(application_form_id)
    area_label = lookup_area(application_form_id)
    region_code = region_code_for(area_label)

    update!(region_code: region_code)
  end

private

  def lookup_area(id)
    application_form = ApplicationForm.find(id)
    return unless application_form&.postcode.present?

    api = Postcodes::IO.new
    result = api.lookup(application_form.postcode)
    result.region
  end

  def region_code_for(area_label)
    # TODO:
    'south_east'
  end
end
