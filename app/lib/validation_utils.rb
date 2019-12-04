module ValidationUtils
  def valid_year?(year)
    year.to_s.match?(/^[1-9]\d{3}$/)
  end
end
