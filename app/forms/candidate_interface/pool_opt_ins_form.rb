class CandidateInterface::PoolOptInsForm
  include ActiveModel::Model
  DEFAULT_RADIUS = 10

  attr_accessor :pool_status
  attr_reader :current_candidate, :preference

  validates :pool_status, presence: true

  def initialize(current_candidate:, preference: nil, params: {})
    @current_candidate = current_candidate
    @preference = preference
    super(params)
  end

  def self.build_from_preference(current_candidate:, preference:)
    new(
      current_candidate:,
      preference:,
      params: {
        pool_status: preference.pool_status,
      },
    )
  end

  def save
    return if invalid?

    if preference.present?
      ActiveRecord::Base.transaction do
        preference.update!(pool_status: pool_status)

        if preference.opt_out?
          preference.published!
          current_candidate.published_preferences.where.not(id: @preference.id).destroy_all
        end

        true
      end
    else
      ActiveRecord::Base.transaction do
        @preference = current_candidate.preferences.create(pool_status:)

        if @preference.opt_out?
          ActiveRecord::Base.transaction do
            # We publish the preference because if they opt out it's the end of the journey
            @preference.published!
            current_candidate.published_preferences.where.not(id: @preference.id).destroy_all
          end
        else
          add_default_location_preferences
        end

        true
      end
    end
  end

private

  def add_default_location_preferences
    application_form = current_candidate.current_cycle_application_form
    sites = application_form.application_choices.map(&:site)

    ActiveRecord::Base.transaction do
      unless application_form.international_address?
        preference.location_preferences.create!(
          name: application_form.postcode,
          within: DEFAULT_RADIUS,
          latitude: application_form.geocode.first,
          longitude: application_form.geocode.last,
        )
      end

      sites.each do |site|
        preference.location_preferences.create!(
          name: site.postcode,
          within: DEFAULT_RADIUS,
          latitude: site.latitude,
          longitude: site.longitude,
          provider_id: site.provider_id,
        )
      end
    end
  end
end
