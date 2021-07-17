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
          postcode: match['btrim'],
          email_address: govuk_link_to(match['email_address'], support_interface_candidate_path(match['candidate_id'])),
        }
      end
    end
  end
end
