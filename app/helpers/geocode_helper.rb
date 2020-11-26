module GeocodeHelper
  def format_average_distance(start, destinations)
    average = CandidateInterface::MeasureDistances.new.average_distance(
      start,
      destinations,
    )
    return 'n/a' if average.blank?

    "#{sprintf('%.1f', average)} miles"
  end
end
