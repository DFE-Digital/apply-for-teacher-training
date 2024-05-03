class ApplicationChoiceHesaExportDecorator < ApplicationChoiceExportDecorator
  def degrees?
    first_degree.present?
  end

  def nationality
    return 'GB' if nationalities.include?('GB')
    return (nationalities & EU_COUNTRY_CODES).first if nationalities.intersect?(EU_COUNTRY_CODES)

    nationalities.first
  end
end
