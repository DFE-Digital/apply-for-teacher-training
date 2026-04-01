module DateValidationHelper
  def valid_or_invalid_date(year, month, day = 1)
    raise ArgumentError if year.blank?

    date_args = [year, month, day].map(&:to_i)

    if date_args[1].zero?
      date_args[1] = Date.strptime(month, '%b').month
    end

    Date.new(*date_args)
  rescue ArgumentError, RangeError
    Struct.new(:day, :month, :year).new(day, month, year)
  end

  def month_and_year_blank?(date)
    return false if date.is_a?(Date)

    date.to_h.slice(:month, :year).all? { |_, v| v.blank? }
  end
end
