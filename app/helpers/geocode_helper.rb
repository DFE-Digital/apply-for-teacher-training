module GeocodeHelper
  def format_distance(start, destination, with_units: true)
    result = CandidateInterface::MeasureDistances.new.distance(
      start,
      destination,
    )

    format_number(result, with_units)
  end

  def format_average_distance(start, destinations, with_units: true)
    average = CandidateInterface::MeasureDistances.new.average_distance(
      start,
      destinations,
    )

    format_number(average, with_units)
  end

private

  def format_number(number, with_units)
    return 'n/a' if number.blank? && with_units
    return '' if number.blank?

    rounded = format('%.1f', number)
    with_units ? "#{rounded} miles" : rounded
  end
end
