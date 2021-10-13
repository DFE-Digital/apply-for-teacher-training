class YearValidator < ActiveModel::EachValidator
  include DateAndYearConcerns

  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, :invalid_year, attribute: humanize(attribute)) if outside_acceptable_age_range(value.to_i)
    record.errors.add(attribute, :multiple_year, attribute: humanize(attribute)) if value.to_s.length > 4
    record.errors.add(attribute, :future, article: article(attribute), attribute: humanize(attribute)) if value.to_i > Time.zone.today.year && options[:future]
  end
end
