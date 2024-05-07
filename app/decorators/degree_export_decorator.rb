class DegreeExportDecorator
  attr_reader :degree
  NO_DEGREE = 'no degree'.freeze

  def initialize(degree)
    @degree = degree
  end

  def qualification_type_hesa_code
    pad_attribute(:qualification_type_hesa_code, 3)
  end

  def subject_hesa_code
    pad_attribute(:subject_hesa_code, 4)
  end

  def grade_hesa_code
    pad_attribute(:grade_hesa_code, 2)
  end

  def institution_country
    pad_attribute(:institution_country, 2)
  end

  def institution_hesa_code
    pad_attribute(:institution_hesa_code, 4)
  end

  def equivalency_details
    pad_attribute(:equivalency_details, 2)
  end

  def start_year
    year_to_iso8601(fetch_attribute(:start_year))
  end

  def award_year
    year_to_iso8601(fetch_attribute(:award_year))
  end

  def enic_reference
    fetch_attribute(:enic_reference)
  end

private

  def fetch_attribute(attribute)
    @degree&.send(attribute)
  end

  def pad_attribute(attribute, pad_by)
    value = fetch_attribute(attribute)
    return NO_DEGREE if @degree.blank?
    return if value.blank?

    value.to_s.rjust(pad_by, '0')
  end

  def year_to_iso8601(year)
    return NO_DEGREE if @degree.blank?
    return if year.blank?

    "#{year}-01-01" if year
  end
end
