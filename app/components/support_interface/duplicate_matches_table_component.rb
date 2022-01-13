module SupportInterface
  class DuplicateMatchesTableComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :matches

    def initialize(matches:)
      @matches = matches
    end

    def self.description_for(match)
      "#{match.candidates.size} candidates with postcode #{match.postcode} and DOB #{match.date_of_birth.to_s(:govuk_date_short_month)}"
    end
  end
end
