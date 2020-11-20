module ValidationUtils
  def valid_year?(year)
    year.to_s.match?(/^[12]\d{3}$/)
  end

  def future_year?(year)
    year.to_i > Time.zone.today.year
  end
end
