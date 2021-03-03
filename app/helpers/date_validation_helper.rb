module DateValidationHelper
  def valid_or_invalid_date(year, month)
    date_args = [year, month, 1].map(&:to_i)
    if year.present? && Date.valid_date?(*date_args)
      Date.new(*date_args)
    else
      Struct.new(:day, :month, :year).new(1, month, year)
    end
  end

  def start_date_before_end_date
    return unless start_date.is_a?(Date) && end_date.is_a?(Date)

    errors.add(:start_date, :before) unless start_date <= end_date
  end

  def month_and_year_blank?(date)
    return false if date.is_a?(Date)

    date.to_h.slice(:month, :year).all? { |_, v| v.blank? }
  end
end
