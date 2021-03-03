class DateValidator < ActiveModel::EachValidator
  include DateAndYearConcerns

  MIN_AGE = 16

  def validate_each(record, attribute, value)
    return if value.blank? || (blank?(value) && !options[:presence])

    date_validations(record, attribute, value) if !record.errors.keys.include?(attribute)

    date_of_birth_validations(record, attribute, value) if options[:date_of_birth] && !record.errors.keys.include?(attribute)
  end

  def date_of_birth_validations(record, attribute, value)
    return record.errors.add(attribute, :dob_future, attribute: humanize(attribute)) if value > Time.zone.today

    record.errors.add(attribute, :dob_below_min_age, date: age_limit.to_s(:govuk_date), min_age: MIN_AGE) if value > age_limit
  end

  def date_validations(record, attribute, value)
    return record.errors.add(attribute, :blank_date, article: article(attribute), attribute: humanize(attribute)) if options[:presence] && blank?(value)

    return record.errors.add(attribute, :blank_date_fields, attribute: humanize(attribute), fields: blank_fields(value).to_sentence) if !blank?(value) && blank_fields(value).any?

    return record.errors.add(attribute, invalid_date_locale(options), article: article(attribute), attribute: humanize(attribute)) if is_invalid?(value)

    return record.errors.add(attribute, :future, article: article(attribute), attribute: humanize(attribute)) if value > Time.zone.today && options[:future]

    record.errors.add(attribute, :before, article: article(attribute), attribute: humanize(attribute), compared_attribute: options[:before]) if options[:before] && !before?(record, value, options[:before])
  end

private

  def age_limit
    Time.zone.today - MIN_AGE.years
  end

  def is_invalid?(value)
    !value.is_a?(Date) || outside_acceptable_age_range(value.year)
  end

  def blank_fields(value)
    return [] if value.is_a?(Date)

    value.to_h.select { |_, v| v.blank? }.keys
  end

  def blank?(value)
    return false if value.is_a?(Date)

    date_fields = %i[day month year]
    date_fields -= [:day] if options[:month_and_year]

    value.to_h.slice(*date_fields).all? { |_, v| v.blank? }
  end

  def invalid_date_locale(options)
    options[:month_and_year] ? :invalid_date_month_and_year : :invalid_date
  end

  def before?(record, value, field_to_compare)
    value_to_compare = record.send(field_to_compare)
    return true unless value_to_compare.is_a?(Date)

    value <= value_to_compare
  end
end
