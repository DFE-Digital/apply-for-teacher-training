module DateValidationHelper
  def valid_or_invalid_date(year, month)
    raise ArgumentError if year.blank?

    date_args = [year, month, 1].map(&:to_i)
    Date.new(*date_args)
  rescue ArgumentError, RangeError
    Struct.new(:day, :month, :year).new(1, month, year)
  end

  def month_and_year_blank?(date)
    return false if date.is_a?(Date)

    date.to_h.slice(:month, :year).all? { |_, v| v.blank? }
  end
end
