class YearValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, :invalid_year, attribute: humanize(attribute)) if outside_acceptable_age_range(value.to_i)
    record.errors.add(attribute, :future, article: article(attribute), attribute: humanize(attribute)) if value.to_i > Time.zone.today.year && options[:future]
  end

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
