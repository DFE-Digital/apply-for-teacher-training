class OLevelAwardYearValidator < ActiveModel::EachValidator
  O_LEVEL_MAX_YEAR = 1989

  def validate_each(record, attribute, award_year)
    return if record.qualification_type != 'gce_o_level'

    record.errors.add(attribute, :gce_o_level_in_future, date: O_LEVEL_MAX_YEAR) if award_year.to_i >= O_LEVEL_MAX_YEAR
  end
end
