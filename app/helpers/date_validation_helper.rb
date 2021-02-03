module DateValidationHelper
  def valid_date_or_nil(year, month)
    date_args = [year, month, 1].map(&:to_i)
    if year.present? && Date.valid_date?(*date_args)
      Date.new(*date_args)
    elsif year.present? || month.present?
      Struct.new(:day, :month, :year).new(1, month, year)
    end
  end

  def valid_or_invalid_date(year, month)
    date_args = [year, month, 1].map(&:to_i)
    if year.present? && Date.valid_date?(*date_args)
      Date.new(*date_args)
    else
      Struct.new(:day, :month, :year).new(1, month, year)
    end
  end

  def start_date_before_end_date
    errors.add(:start_date, :before) unless start_date <= end_date
  end
end
