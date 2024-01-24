module CandidateDetailsHelper
  def includes_eu_eea_swiss?(nationalities)
    EU_EEA_SWISS_COUNTRY_CODES.intersect?(nationalities.map { |name| NATIONALITIES_BY_NAME[name] })
  end
end
