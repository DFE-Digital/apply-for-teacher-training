class LookupAreaByPostcodeWorker
  include Sidekiq::Worker

  REGION_CODES = {
    'north east' => :north_east,
    'north west' => :north_west,
    'yorkshire and the humber' => :yorkshire_and_the_humber,
    'east midlands' => :east_midlands,
    'west midlands' => :west_midlands,
    'east of england' => :eastern,
    'london' => :london,
    'south east' => :south_east,
    'south west' => :south_west,
    'wales' => :wales,
    'scotland' => :scotland,
    'northern ireland' => :northern_ireland,
    'channel islands' => :channel_islands,
    'isle of man' => :isle_of_man,
  }.freeze

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
    if result.region.present?
      REGION_CODES[result.region.downcase]
    elsif result.country.present?
      REGION_CODES[result.country.downcase]
    end
  end
end
