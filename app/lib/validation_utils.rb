module ValidationUtils
  def valid_year?(year)
    year.to_s.match?(/^[12]\d{3}$/)
  end
end
