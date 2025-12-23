class LookupAreaByPostcodeWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low_priority, retry: 5

  def perform(application_form_id)
    application_form = ApplicationForm.find(application_form_id)
    return if application_form&.postcode.blank?

    application_form.update!(
      region_code: region_code_for(
        lookup_area(application_form.postcode),
      ),
    )
  end

private

  def lookup_area(postcode)
    api = Postcodes::IO.new
    api.lookup(postcode)
  end

  def region_code_for(result)
    if result&.region.present?
      REGION_CODES[result.region.downcase]
    elsif result&.country.present?
      REGION_CODES[result.country.downcase]
    end
  end
end
