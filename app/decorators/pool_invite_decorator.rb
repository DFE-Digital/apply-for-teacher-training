class PoolInviteDecorator < SimpleDelegator
  def closest_location_preference_to_site
    return nil if candidate.published_preferences.blank? ||
                  candidate.published_preferences.last.training_locations_anywhere?

    @closest_location_preference_to_site ||= sites_close_to_location_preferences.first
  end

  def site_distance
    closest_location_preference_to_site&.distance
  end

  def closest_location_name
    closest_location_preference_to_site&.name
  end

private

  def sites_close_to_location_preferences
    course.sites.flat_map do |site|
      # the nearest comes first
      closest_site = candidate.published_location_preferences.near(
        [site.latitude, site.longitude],
        :within,
      ).first

      closest_site.presence || []
    end.sort_by(&:distance)
  end
end
