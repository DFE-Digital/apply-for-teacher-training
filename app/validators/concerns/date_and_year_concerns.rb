module DateAndYearConcerns
  extend ActiveSupport::Concern

  def outside_acceptable_age_range(value)
    !(100.years.ago.year..2999).cover?(value)
  end

  def article(attribute)
    %w[a e i o u].include?(attribute.to_s.first) ? 'an' : 'a'
  end

  def humanize(attribute)
    attribute.to_s.humanize(capitalize: false)
  end
end
