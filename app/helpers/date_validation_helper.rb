module DateValidationHelper
  def valid_end_date_or_nil(year, month)
    date_args = [year, month, 1].map(&:to_i)
    if year.present? && Date.valid_date?(*date_args)
      Date.new(*date_args)
    elsif year.present? || month.present?
      Struct.new(:day, :month, :year).new(1, month, year)
    end
  end

  def valid_or_invalid_start_date(year, month)
    date_args = [year, month, 1].map(&:to_i)
    if year.present? && Date.valid_date?(*date_args)
      Date.new(*date_args)
    else
      Struct.new(:day, :month, :year).new(1, month, year)
    end
  end

  def end_date_blank?
    end_date_year.blank? && end_date_month.blank?
  end

  def end_date_valid
    errors.add(:end_date, :invalid) unless end_date.is_a?(Date)
  end

  def start_date_valid
    errors.add(:start_date, :invalid) unless start_date.is_a?(Date)
  end

  def start_date_before_end_date
    if start_date_and_end_date_valid?
      errors.add(:start_date, :before) unless start_date <= end_date
    end
  end

  def end_date_before_current_year_and_month
    if end_date.year > Time.zone.today.year || \
        end_date.year == Time.zone.today.year && end_date.month > Time.zone.today.month
      errors.add(:end_date, :in_the_future)
    end
  end

  def start_date_and_end_date_valid?
    end_date.is_a?(Date) && start_date.is_a?(Date)
  end

  def end_date_valid?
    end_date.is_a?(Date)
  end
end
