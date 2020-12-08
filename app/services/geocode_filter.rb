class GeocodeFilter
  SOUTHERLY_LIMIT = 49.51
  NORTHERLY_LIMIT = 60.51
  WESTERLY_LIMIT = -8.638
  EASTERLY_LIMIT = 1.46

  def outside_uk_or_unknown?(coordinates)
    latitude, longitude = coordinates
    (latitude.blank? || longitude.blank?) ||
      latitude < SOUTHERLY_LIMIT ||
      latitude > NORTHERLY_LIMIT ||
      longitude < WESTERLY_LIMIT ||
      longitude > EASTERLY_LIMIT
  end
end
