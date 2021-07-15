module SupportInterface
  class DuplicateCandidateMatchesTableComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :matches

    def initialize(matches:)
      @matches = matches
    end

    def table_rows
      matches.map do |match|
        {
          candidate_id: match['candidate_id'],
          first_name: match['first_name'],
          last_name: match['last_name'],
          date_of_birth: match['date_of_birth'],
          postcode: match['postcode'],
          email_address: match['email_address'],
        }
      end
    end
  end
end
