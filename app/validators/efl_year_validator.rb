class EflYearValidator < ActiveModel::EachValidator
  YEAR_REGEX = /^\d{4}$/.freeze

  def validate_each(record, attribute, value)
    return if value.blank?

    return record.errors.add(attribute, :not_a_year) if not_a_year(value.to_s)
    return record.errors.add(attribute, :invalid) if outside_efl_start_years(record, value.to_i)
    return record.errors.add(attribute, :future) if value.to_i > Time.zone.today.year
  end

private

  def not_a_year(value)
    value !~ YEAR_REGEX
  end

  def outside_efl_start_years(record, value)
    value < if record.model_name.human == 'Other efl qualification form'
              1900
            elsif record.model_name.human == 'Ielts form'
              1980
            else
              1964
            end
  end
end
