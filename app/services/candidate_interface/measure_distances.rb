module CandidateInterface
  class MeasureDistances
    def average_distance(start, destinations)
      return nil unless has_coordinates?(start)

      distances = destinations.map { |destination| distance(start, destination) }.compact
      return nil if distances.blank?

      distances.sum(0.0) / distances.size
    end

    def distance(from, to)
      return nil unless has_coordinates?(from) && has_coordinates?(to)

      Geocoder::Calculations.distance_between(
        [from.latitude, from.longitude],
        [to.latitude, to.longitude],
      )
    end

  private

    def has_coordinates?(model)
      model&.geocoded?
    end
  end
end
