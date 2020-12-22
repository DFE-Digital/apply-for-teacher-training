class ApplicationChoiceHesaExportDecorator < ApplicationChoiceExportDecorator
  def nationality
    return 'GB' if nationalities.include?('GB')
    return (nationalities & EU_COUNTRY_CODES).first if (nationalities & EU_COUNTRY_CODES).any?

    nationalities.first
  end
end
