module CandidateInterface
  class MeasureDistances
    def average_distance(start, destinations)
      return nil unless has_coordinates?(start)

      distances = destinations.map do |destination|
        distance(start, destination)
      end.compact
      return nil if distances.blank?

      distances.sum(0.0) / distances.size
    end

  private
    def distance(from, to)
      return nil unless has_coordinates?(from) && has_coordinates?(to)

      Geocoder::Calculations.distance_between(
        [from.latitude, from.longitude],
        [to.latitude, to.longitude],
      )
    end

    def has_coordinates?(model)
      !model.latitude.nil? && !model.longitude.nil?
    end
  end
end
