module SupportInterface
  class DuplicateMatchesTableComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :matches

    def initialize(matches:)
      @matches = matches
    end

    def description_for(match)
      "#{match.candidates.size} candidates with postcode #{match.postcode} and DOB #{I18n.l(match.date_of_birth, format: '%d/%m/%Y')}"
    end

  private

  end
end
